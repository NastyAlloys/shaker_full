Pod::Spec.new do |s|
  s.name             = "NHAppCore"
  s.version          = "0.1.9"
  s.summary          = "A short description of NHAppCore."
  s.license          = 'MIT'
  s.author           = { "Naithar" => "devias.naith@gmail.com" }
  s.source           = { :git => "https://github.com/dekakisalove/shaker_core.git", :tag => s.version.to_s }
  s.homepage         = "https://github.com/shakerapp/shaker_core"
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'NHAppCore/Pod/Classes/**/*'
  s.public_header_files = 'NHAppCore/Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'CFNetwork', 'Security', 'Foundation'
  s.libraries = 'icucore'
  s.dependency 'AFNetworking', '~> 2'
  s.dependency 'UICKeyChainStore', '>=2.0'
  s.dependency 'Reachability', '>= 3.2'
  s.dependency 'NHSearchController'
end
