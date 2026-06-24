platform :ios, '14.0'

target 'DHLCustomUploadPhotoView' do
  #use_frameworks!

  # Pods for DHLCustomLib
  pod 'Alamofire'
  pod 'DHLFourButtonsModal'
  pod 'DHLLoadingAnimation'
  
end

ENV["COCOAPODS_DISABLE_STATS"] = "true"

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      end
    end
  end
end
