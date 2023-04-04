# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'BlindDateApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  plugin 'cocoapods-imy-bin'
  use_binaries!
  use_frameworks!
  use_modular_headers!

  # Pods for BlindDateApp
  pod 'Alamofire'
  pod 'XCGLogger', '~> 7.0.1'
  pod 'SDWebImageSwiftUI'
  pod 'HandyJSON', '~> 5.0.2'
  pod 'JFHeroBrowser', '1.2.0'
  pod 'Introspect'
  pod 'TXIMSDK_Plus_Swift_iOS_Bitcode'

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
         end
    end
  end
end
