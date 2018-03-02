# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!

def project_pods
    react_path = './node_modules/react-native'
    yoga_path = File.join(react_path, 'ReactCommon/yoga')

    pod 'React', :path => './node_modules/react-native', :subspecs => [
    'Core',
    'DevSupport',
    'BatchedBridge',
    'RCTText',
    'RCTNetwork',
    'RCTWebSocket',
    'RCTImage',
    ]
    pod 'yoga', :path => yoga_path
    pod 'RNFS', :path => './node_modules/react-native-fs'
#    pod 'react-native-webrtc', :path => './node_modules/react-native-webrtc'
    pod 'RNDeviceInfo', :path => './node_modules/react-native-device-info'
    pod 'RNSqlite2', :path => './node_modules/react-native-sqlite-2/ios/'
    pod 'RNViewShot', :path => './node_modules/react-native-view-shot/'
    pod 'CRToast'
    pod 'SVProgressHUD'
end

target 'Client' do
    project_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
