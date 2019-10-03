#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'native_pdf_renderer'
  s.version          = '1.0.0'
  s.summary          = 'Plugin to render PDF pages as images.'
  s.description      = <<-DESC
Flutter Plugin to render a PDF file.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Serge Shkurko' => 'sergeshkurko@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.swift_version = '5.0'

  s.ios.deployment_target = '8.0'
end

