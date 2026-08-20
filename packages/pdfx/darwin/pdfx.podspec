#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pdfx.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pdfx'
  s.version          = '1.0.0'
  s.summary          = 'Flutter Plugin to render a PDF file.'
  s.description      = <<-DESC
Flutter Plugin to render a PDF file.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/ScerIO/packages.flutter/tree/main/packages/pdfx'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Serge Shkurko' => 'sergeshkurko@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'pdfx/Sources/**/*.{h,m,swift}'
  s.public_header_files = 'pdfx/Sources/**/include/**/*.h'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  # Flutter.framework does not contain an i386 slice.
  s.ios.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
