Pod::Spec.new do |s|
  s.name             = "NHSearchController"
  s.version          = "0.6.7"
  s.summary          = "custom search view with result table view"
  s.homepage         = "https://github.com/naithar/NHSearchController"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Naithar" => "devias.naith@gmail.com" }
  s.source           = { :git => "https://github.com/naithar/NHSearchController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/naithar'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resources = ['Pod/Assets/*']

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
