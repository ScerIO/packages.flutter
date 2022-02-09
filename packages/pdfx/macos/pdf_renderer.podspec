#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pdf_renderer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pdf_renderer'
  s.version          = '1.0.0'
  s.summary          = 'Flutter Plugin to render a PDF file.'
  s.description      = <<-DESC
  Flutter Plugin to render a PDF file.
  Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/rbcprolabs/packages.flutter/tree/master/packages/pdf_renderer'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Serge Shkurko' => 'sergeshkurko@outlook.com' }
  s.source           = { :http => 'https://github.com/rbcprolabs/packages.flutter/tree/master/packages/pdf_renderer' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
