#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'permission_handler_apple'
  s.version          = '9.4.8'
  s.summary          = 'Permission plugin for Flutter.'
  s.description      = <<-DESC
Permission plugin for Flutter. This plugin provides a cross-platform (iOS, Android) API to request and check permissions.
                       DESC
  s.homepage         = 'https://github.com/baseflowit/flutter-permission-handler'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Baseflow' => 'hello@baseflow.com' }
  s.source           = { :path => '.' }
  s.source_files = 'permission_handler_apple/Sources/permission_handler_apple/**/*.{h,m}'
  s.public_header_files = 'permission_handler_apple/Sources/permission_handler_apple/include/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '12.0'
  s.static_framework = true
  s.resource_bundles = {'permission_handler_apple_privacy' => ['permission_handler_apple/Sources/permission_handler_apple/PrivacyInfo.xcprivacy']}
end

