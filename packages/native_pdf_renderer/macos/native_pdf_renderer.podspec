#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_pdf_renderer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_pdf_renderer'
  s.version          = '1.1.0'
  s.summary          = 'Flutter Plugin to render a PDF file.'
  s.description      = <<-DESC
  Flutter Plugin to render a PDF file.
                       DESC
  s.homepage         = 'http://serge.software'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Serge Shkurko' => 'sergeshkurko@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
