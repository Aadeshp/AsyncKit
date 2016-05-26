#
# Be sure to run `pod lib lint AsyncKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AsyncKit'
  s.version          = '0.1.0'
  s.summary          = 'Brings the power of promises/futures to iOS development in the form of Tasks'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Check out the thorough documentation at https://aadeshp.github.io/async-kit
                       DESC

  s.homepage         = 'https://github.com/aadeshp/AsyncKit'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aadesh Patel' => 'aadeshp95@gmail.com' }
  s.source           = { :git => 'https://github.com/aadeshp/AsyncKit.git', :tag => "v" + s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AsyncKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AsyncKit' => ['AsyncKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
