# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

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
    pod 'react-native-webrtc', :path => './node_modules/react-native-webrtc'
    pod 'RNDeviceInfo', :path => './node_modules/react-native-device-info'
    pod 'RNSqlite2', :path => './node_modules/react-native-sqlite-2/ios/'
    pod 'RNViewShot', :path => './node_modules/react-native-view-shot/'
end


target 'Client' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Client
  project_pods

  target 'ClientTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

