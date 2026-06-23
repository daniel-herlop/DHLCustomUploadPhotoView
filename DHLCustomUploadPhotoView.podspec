Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '14.0'
s.name = "DHLCustomUploadPhotoView"
s.summary = "Vistas custom para adjuntar y visualizar fotos y documentos"
s.requires_arc = true

s.version = "1.0.4"

s.license = { :type => "MIT", :file => "LICENSE" }

s.author = { "Daniel Hernandez Lopez" => "hzlzdaniel@gmail.com" }

s.homepage = "https://github.com/daniel-herlop/DHLCustomUploadPhotoView"

s.source = { :git => "https://github.com/daniel-herlop/DHLCustomUploadPhotoView.git", 
             :tag => "#{s.version}" }

s.framework = "UIKit"
s.dependency 'Alamofire'
s.dependency 'DHLFourButtonsModal'

s.source_files = "DHLCustomUploadPhotoView/**/*.{swift}"

s.resources = "DHLCustomUploadPhotoView/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,strings}"

s.swift_version = "5.0"

end