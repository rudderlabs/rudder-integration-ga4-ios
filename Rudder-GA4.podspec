Pod::Spec.new do |s|
  s.name             = 'Rudder-GA4'
  s.version          = '1.0.0'
  s.summary          = 'Privacy and Security focused Segment-alternative. Firebase Native SDK integration support for Google Analytics 4.'

  s.description      = <<-DESC
  Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
                       DESC
  s.homepage         = 'https://github.com/rudderlabs/rudder-integration-ga4-ios'
  s.license          = { :type => "Apache", :file => "LICENSE" }
  s.author           = { 'RudderStack' => 'arnab@rudderlabs.com' }
  s.source           = { :git => 'https://github.com/rudderlabs/rudder-integration-ga4-ios.git' , :tag => "v#{s.version}"}
  s.platform         = :ios, "9.0"
  s.requires_arc = true

  s.ios.deployment_target = '9.0'

  s.source_files = 'Rudder-GA4/Classes/**/*'

  s.static_framework = true

  s.dependency 'Rudder', '~> 1.0'
  s.dependency 'Firebase/Analytics', '~> 8.15.0'
end
