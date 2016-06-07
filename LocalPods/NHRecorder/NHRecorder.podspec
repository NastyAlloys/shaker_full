#
# Be sure to run `pod lib lint NHRecorder.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NHRecorder"
  s.version          = "0.6.2"
  s.summary          = "Custom ios camera"
#  s.description      = <<-DESC
#                       An optional longer description of NHRecorder
#
#                       * Markdown format.
#                       * Don't worry about the indent, we strip it!
#                       DESC
  s.homepage         = "https://github.com/naithar/NHRecorder"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Naithar" => "devias.naith@gmail.com" }
  s.source           = { :git => "https://github.com/naithar/NHRecorder.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/naithar'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resources = ['Pod/Assets/Filters/*', 'Pod/Assets/*']

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.private_header_files = 'Pod/Classes/Private/*.h'
  s.dependency 'GPUImage'
  s.frameworks   = ['UIKit', 'CoreGraphics', 'Foundation', 'QuartzCore', 'MobileCoreServices', 'MediaPlayer', 'CoreMedia', 'AssetsLibrary', 'AVFoundation']
end
