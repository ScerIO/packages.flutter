#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_pdf_renderer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_pdf_renderer'
  s.version          = '1.2.0'
  s.summary          = 'Flutter Plugin to render a PDF file.'
  s.description      = <<-DESC
Flutter Plugin to render a PDF file.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Serge Shkurko' => 'sergeshkurko@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
