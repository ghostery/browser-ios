#!/bin/env groovy

@Library('cliqz-shared-library@vagrant') _

node('mac-mini-ios') {

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
                        if [ "$1" == "--force" ]; then
                            rm -rf Carthage/*
                            rm -rf ~/Library/Caches/org.carthage.CarthageKit
                        fi
                        CARTHAGE_VERBOSE=""
                        if [ ! -z "$XCS_BOT_ID"  ]; then
                            CARTHAGE_VERBOSE="--verbose"
                        fi
                        carthage bootstrap $CARTHAGE_VERBOSE --platform ios --color auto --cache-builds
                        npm install
                        npm run build
                        pod install
                        npm run bundle
                    '''
                }
                stage('Build') {
                    timeout(20) {
                        sh '''#!/bin/bash -l
                            set -e
                            xcodebuild \
                                -workspace Client.xcworkspace \
                                -scheme "Fennec" \
                                -sdk iphonesimulator \
                                -destination "platform=iOS Simulator,OS=11.2,id=185B34BB-DCB8-4A17-BDCA-843086B67193" \
                                ONLY_ACTIVE_ARCH=NO \
                                -derivedDataPath clean build test
                        '''
                    }
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
                                npm run appium
                                sleep 15
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
                        xcrun simctl boot 185B34BB-DCB8-4A17-BDCA-843086B67193 || true
                        xcrun simctl uninstall booted com.cliqz.ios.newCliqz
                        xcrun simctl uninstall booted com.apple.test.WebDriverAgentRunner-Runner
                        xcrun simctl uninstall booted com.apple.test.AppiumTests-Runner
                        xcrun simctl shutdown 185B34BB-DCB8-4A17-BDCA-843086B67193 || true
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