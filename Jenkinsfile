#!/bin/env groovy

@Library('cliqz-shared-library@vagrant') _

node('mac-mini-ios') {
    writeFile file: 'Vagrantfile', text: '''
    Vagrant.configure("2") do |config|
        config.vm.box = "ios-xcode9.3"
    
        config.vm.define "priosx93" do |priosx93|
            priosx93.vm.hostname = "priosx93"
            
            priosx93.vm.network "public_network", :bridge => "en0", auto_config: false
            priosx93.vm.boot_timeout = 900
            priosx93.vm.provider "vmware_fusion" do |v|
                v.name = "priosx93"
                v.whitelist_verified = true
                v.gui = false
                v.memory = ENV["NODE_MEMORY"]
                v.cpus = ENV["NODE_CPU_COUNT"]
                v.cpu_mode = "host-passthrough"
                v.vmx["remotedisplay.vnc.enabled"] = "TRUE"
                v.vmx["RemoteDisplay.vnc.port"] = ENV["NODE_VNC_PORT"]
                v.vmx["ethernet0.pcislotnumber"] = "33"
            end
            priosx93.vm.provision "shell", privileged: false, run: "always", inline: <<-SHELL#!/bin/bash -l
                set -e
                set -x
                rm -f agent.jar
                curl -LO #{ENV['JENKINS_URL']}/jnlpJars/agent.jar
                nohup java -jar agent.jar -jnlpUrl #{ENV['JENKINS_URL']}/computer/#{ENV['NODE_ID']}/slave-agent.jnlp -secret #{ENV["NODE_SECRET"]} &
            SHELL
        end
    end
    '''
    
    def jobStatus = 'FAIL'

    vagrant.inside(
        'Vagrantfile',
        '/jenkins',
        4, // CPU
        8000, // MEMORY
        12000, // VNC port
        false, // rebuild image
    ) { 
        nodeId ->
        node(nodeId) {
            try {
                stage("Checkout") {
                    checkout scm
                    withCredentials([file(credentialsId: 'ceb2d5e9-fc88-418f-aa65-ce0e0d2a7ea1', variable: 'SSH_KEY')]) {
                        cloneRepoViaSSH(
                            'git@github.com:cliqz/autobots.git',
                            '-b version2.0 --single-branch --depth=1'
                        )
                    }
                }
                stage('Prepare Environment') {
                    sh '''#!/bin/bash -l
                        set -e
                        set -x
                        brew update
                        brew list carthage &>/dev/null || brew install carthage
                        brew list python2 &>/dev/null || brew install python2
                        sudo -H python2 -m ensurepip
                        chmod 0755 autobots/requirements.txt
                        sudo -H python2 -m pip install -vvvr autobots/requirements.txt
                    '''
                }
                stage('Setup Build Environment') {
                    sh '''#!/bin/bash -l
                        set -e
                        set -x
                        rm -rf Carthage/*
                        rm -rf ~/Library/Caches/org.carthage.CarthageKit
                        CARTHAGE_VERBOSE=""
                        if [ ! -z "$XCS_BOT_ID"  ]; then
                            CARTHAGE_VERBOSE="--verbose"
                        fi
                        carthage bootstrap $CARTHAGE_VERBOSE --platform ios --color auto --cache-builds
                        npm install
                        npm run debug-channel
                        npm run build
                        pod install
                        npm run bundle
                    '''
                }
                stage('Build') {
                    timeout(60) {
                        sh '''#!/bin/bash -l
                            set -e
                            xcodebuild \
                                -workspace Client.xcworkspace \
                                -scheme "Fennec" \
                                -sdk iphonesimulator \
                                -destination "platform=iOS Simulator,OS=11.3,id=8A112602-53F8-4996-A58A-FC65665635EB" \
                                OTHER_SWIFT_FLAGS='$(value) -DAUTOMATION' \
                                ONLY_ACTIVE_ARCH=NO \
                                -derivedDataPath clean build test
                        '''
                    }
                }
                stage('Run Tests') {
                    withEnv([
                        'platformName=ios',
                        'udid=8A112602-53F8-4996-A58A-FC65665635EB',
                        'deviceName=iPhone 6s',
                        'platformVersion=11.3',
                        'bundleID=com.cliqz.ios.newCliqz'
                        ]) {
                        timeout(60) {
                            sh '''#!/bin/bash -l
                                set -x
                                set -e
                                npm run appium
                                sleep 15
                                python autobots/testRunner.py
                            '''
                        }
                    }
                }
                jobStatus = 'PASS'
            }
            catch(all) {
                jobStatus = 'FAIL'
            }
            finally {
                stage('Upload Results') {
                    archiveTestResults()
                }
                stage('Cleanup') {
                    sh '''#!/bin/bash -l
                        set -x
                        kill $(ps -A | grep -m1 appium | awk '{print \$1}')
                        rm -rf *.log\
                            autobots \
                            Cartfile.resolved \
                            Carthage \
                            node_modules \
                            Podfile.lock \
                            Pods \
                            screenshots \
                            screenshots.zip \
                            test-reports
                        xcrun simctl boot 8A112602-53F8-4996-A58A-FC65665635EB || true
                        xcrun simctl uninstall booted com.cliqz.ios.newCliqz
                        xcrun simctl uninstall booted com.apple.test.WebDriverAgentRunner-Runner
                        xcrun simctl uninstall booted com.apple.test.AppiumTests-Runner
                        xcrun simctl shutdown 8A112602-53F8-4996-A58A-FC65665635EB || true
                    '''
                }
            }
        }
    }
    if (jobStatus == 'FAIL') {
        error "Something Failed. Check the above logs."
    }
}

def cloneRepoViaSSH(String repoLink, String args) {
    sh """#!/bin/bash -l
        set -x
        set -e
        mkdir -p ~/.ssh
        cp $SSH_KEY ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
        ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
        git clone ${args} ${repoLink}
    """
}

def archiveTestResults() {
    try {
        archiveArtifacts allowEmptyArchive: true, artifacts: '*.log'
        junit 'test-reports/*.xml'
        zip archive: true, dir: 'screenshots', glob: '', zipFile: 'screenshots.zip'
    } catch(e) {
        print e
    }
}