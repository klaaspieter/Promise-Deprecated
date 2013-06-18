Pod::Spec.new do |s|
  s.name         = "Promise"
  s.version      = "0.0.1"
  s.summary      = "An Objective-C implementation of the Javascript Promises/A+ spec."
  s.homepage     = "https://github.com/klaaspieter/Promise"
  s.license      = 'MIT'
  s.author       = { "Klaas Pieter Annema" => "klaaspieter@annema.me" }
  s.source       = { :git => "https://github.com/klaaspieter/Promise.git", :tag => "0.0.1" }
  s.ios.deployment_target = '6.0'
  # s.osx.deployment_target = '10.7'
  s.source_files = 'Promise/**/*.{h,m}'
  s.requires_arc = true
end
