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

  # Preserve the existing CocoaPods deployment targets while SwiftPM uses
  # Flutter's current iOS and macOS minimums in Package.swift.
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'

  # Flutter.framework does not contain an i386 slice.
  s.ios.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.osx.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
