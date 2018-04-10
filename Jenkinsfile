#!/bin/env groovy

@Library('cliqz-shared-library@vagrant') _

node('mac-mini-ios') {
    writeFile file: 'Vagrantfile', text: '''
    Vagrant.configure("2") do |config|
        config.vm.box = "ios-xcode9.2"
        
        config.vm.define "priosx92" do |priosx92|
            priosx92.vm.hostname ="priosx92"
            
            priosx92.vm.network "public_network", :bridge => "en0", auto_config: false
            priosx92.vm.boot_timeout = 900
            priosx92.vm.provider "vmware_fusion" do |v|
                v.name = "priosx92"
                v.whitelist_verified = true
                v.gui = false
                v.memory = ENV["NODE_MEMORY"]
                v.cpus = ENV["NODE_CPU_COUNT"]
                v.cpu_mode = "host-passthrough"
                v.vmx["remotedisplay.vnc.enabled"] = "TRUE"
                v.vmx["RemoteDisplay.vnc.port"] = ENV["NODE_VNC_PORT"]
                v.vmx["ethernet0.pcislotnumber"] = "33"
            end
            priosx92.vm.provision "shell", privileged: false, run: "always", inline: <<-SHELL#!/bin/bash -l
                set -e
                set -x
                rm -f agent.jar
                curl -LO #{ENV['JENKINS_URL']}/jnlpJars/agent.jar
                nohup java -jar agent.jar -jnlpUrl #{ENV['JENKINS_URL']}/computer/#{ENV['NODE_ID']}/slave-agent.jnlp -secret #{ENV["NODE_SECRET"]} &
            SHELL
        end
    end
    '''

    def jobStatus = ""

    vagrant.inside(
        'Vagrantfile',
        '/jenkins',
        2, // CPU
        4000, // MEMORY
        12000, // VNC port
        false, // rebuild image
    ) { 
        nodeId ->
        node(nodeId) {
            try {
                stage("Checkout") {
                    checkout scm
                    withCredentials([file(credentialsId: 'ceb2d5e9-fc88-418f-aa65-ce0e0d2a7ea1', variable: 'CLIQZ_CI_SSH_KEY')]) {
                        sh '''#!/bin/bash -l
                            set -x
                            set -e
                            mkdir -p ~/.ssh
                            cp $CLIQZ_CI_SSH_KEY ~/.ssh/id_rsa
                            chmod 600 ~/.ssh/id_rsa
                            echo $CLIQZ_CI_SSH_KEY
                            ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
                            sudo -H python -m ensurepip
                            sudo -H pip install --upgrade pip
                            git clone -b version2.0 --single-branch --depth=1 git@github.com:cliqz/autobots.git
                        '''
                    }
                }
                stage('Prepare') {
                    sh '''#!/bin/bash -l
                        set -e
                        set -x
                        brew update
                        brew list carthage &>/dev/null || brew install carthage
                        npm -g install yarn
                        rm -rf Cartfile.resolved
                        ./bootstrap.sh
                        yarn install
                        pod install
                    '''
                }
                stage('Build') {
                    timeout(10) {
                        sh '''#!/bin/bash -l
                            set -e
                            xcodebuild -workspace Client.xcworkspace -scheme "Fennec" -sdk iphonesimulator -destination "platform=iOS Simulator,OS=11.2,id=185B34BB-DCB8-4A17-BDCA-843086B67193" ONLY_ACTIVE_ARCH=NO -derivedDataPath clean build
                        '''
                    }
                }
                stage('Setup Test Environment'){
                    sh '''#!/bin/bash -l
                        set -e
                        npm install -g appium
                        npm install -g wd
                        appium &
                        echo $! > appium.pid
                    '''
                }
                stage('Run Tests') {
                    withEnv([
                        'platformName=ios',
                        'udid=185B34BB-DCB8-4A17-BDCA-843086B67193',
                        'deviceName=iPhone 6',
                        'platformVersion=11.2',
                        'MODULE=testSmoke',
                        'TEST=SmokeTest',
                        'bundleID=com.cliqz.ios.newCliqz'
                        ]) {
                        timeout(60) {
                            sh '''#!/bin/bash -l
                                set -x
                                set -e
                                chmod 0755 autobots/requirements.txt
                                sudo -H pip install -r autobots/requirements.txt
                                sleep 10
                                python autobots/testRunner.py
                            '''
                        }
                    }
                }
            }
            catch(all) {
                jobStatus = 'FAIL'
            }
            finally {
                stage('Upload Results') {
                    try {
                        archiveArtifacts allowEmptyArchive: true, artifacts: 'autobots/*.log'
                        junit "autobots/test-reports/*.xml"
                        zip archive: true, dir: 'autobots/screenshots', glob: '', zipFile: 'autobots/screenshots.zip'
                    } catch (e) {
                        // no screenshots, no problem
                    }
                }
                stage('Cleanup') {
                    sh '''#!/bin/bash -l
                        set -x
                        set -e
                        kill `cat appium.pid` || true
                        rm -f appium.pid
                        xcrun simctl uninstall booted com.cliqz.ios.newCliqz || true
                        xcrun simctl uninstall booted com.apple.test.WebDriverAgentRunner-Runner || true
                        xcrun simctl uninstall booted com.apple.test.AppiumTests-Runner || true
                        rm -rf autobots
                        npm uninstall -g appium
                        npm uninstall -g wd
                    '''
                }
            }
        }
    }
    if (jobStatus == 'FAIL') {
        error "Something Failed. Check the above logs."
    }
}
