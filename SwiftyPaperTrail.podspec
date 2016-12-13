#
# Be sure to run `pod lib lint SwiftyPaperTrail.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftyPaperTrail'
  s.version          = '0.1.0'
  s.summary          = 'SwiftyLogger Papertrail adapter.'

  s.description      = <<-DESC
Adapter from SwiftyLogger to Papertrail via nonblocking socket operation.s
                       DESC

  s.homepage         = 'https://github.com/Rhumbix/SwiftyPaperTrail'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mark Eschbach' => 'mark@rhumbix.com' }
  s.source           = { :git => 'https://github.com/Rhumbix/SwiftyPaperTrail.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'SwiftyPaperTrail/**/*'
  s.dependency 'CocoaAsyncSocket'
end
