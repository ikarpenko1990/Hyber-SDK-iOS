#
# Be sure to run `pod lib lint Hyber.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Hyber'
  s.version          = '2.2.0'
  s.summary          = 'Hyber SDK for IOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Hyber SDK for IOS. Implement push notification and other Hyber functionality.
                       DESC

  s.homepage         = 'https://github.com/Incuube/Hyber-SDK-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Taras Markevych' => 't.markevych@incuube.com' }
  s.source           = { :git => 'https://github.com/Incuube/Hyber-SDK-iOS.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/lulz_ua'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Hyber/Classes/**/*'
  s.preserve_paths = 'Hyber/Classes/SupportFiles/module.modulemap'

  # s.preserve_path = "${POD_ROOT}/Classes/SupportFiles/Header-Bridging-Header.h"
  #s.xcconfig = { 'SWIFT_OBJC_BRIDGING_HEADER' => '${POD_ROOT}/Classes/SupportFiles/Header-Bridging-Header.h' } 

  # s.resource_bundles = {
  #   'Hyber' => ['Hyber/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  #s.frameworks = 'CommonCrypto'
  s.dependency 'Alamofire', '~> 4.0.1'
  s.dependency 'Firebase/Core', '3.7.1'
  s.dependency 'Firebase/Messaging', '3.7.1'
  s.dependency 'RealmSwift', '2.0.3'
  s.dependency 'RxSwift', '3.0.0-rc.1'
  #s.dependency 'RxCocoa', '3.0.0-rc.1'
  s.dependency 'ObjectMapper', '~> 2.1.0'
  s.dependency 'SwiftyJSON', '3.1.1'
  s.dependency 'CryptoSwift','0.6.6'
  


end
