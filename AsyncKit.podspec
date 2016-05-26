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
  s.summary          = 'AsyncKit brings the power of promises/futures to iOS development in the form of Tasks'

  s.description      = <<-DESC
AsyncKit brings the power of promises/futures to iOS development in the form of Tasks. A task is essentially a wrapper of an asynchronous function's return value and can be accessed using the then method on the task object.

Check out the thorough documentation at https://aadeshp.github.io/async-kit
                       DESC

  s.homepage         = 'https://github.com/aadeshp/AsyncKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aadesh Patel' => 'aadeshp95@gmail.com' }
  s.source           = { :git => 'https://github.com/aadeshp/AsyncKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'AsyncKit/Classes/**/*'
end
