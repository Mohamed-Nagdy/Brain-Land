# Stands in for the google_mobile_ads plugin on iOS: registers nothing and
# links no advertising SDK. Brain Land shows no ads on iOS (App Store
# guideline 5.1.4); the Dart side never calls the ads plugin there.
Pod::Spec.new do |s|
  s.name             = 'google_mobile_ads'
  s.version          = '0.0.1'
  s.summary          = 'No-op iOS stand-in for google_mobile_ads.'
  s.homepage         = 'https://athryza.com'
  s.license          = { :type => 'Proprietary' }
  s.author           = 'ATHRYZA Technologies'
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform         = :ios, '15.0'
end
