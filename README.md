[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://swift.org/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://swift.org/)
[![Build Status](https://travis-ci.org/GMSLabs/Hyber-SDK-iOS.svg?branch=master)](https://travis-ci.org/GMSLabs/Hyber-SDK-iOS)

### Installation

#### CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Hyber into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

pre_install do |installer|
  # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
  def installer.verify_no_static_framework_transitive_dependencies; end
end

pod 'Hyber/Inbox', :git => 'https://github.com/GMSLabs/Hyber-SDK-iOS.git', :tag => '0.1.2'
```

Then, run the following command:

```bash
$ pod install
```

#### Add files
Add [```HyberFirebaseMessagingDelegate.swift```][HyberFirebaseMessagingDelegateLink] file to your project

#### Configure target
Disable bitcode (set `ENABLE_BITCODE` to `false`) in build settings for your target. See Google Cloud Messaging [issue](https://github.com/google/gcm/issues/91)

#### Modify AppDelegate
##### Add ```import``` statement
```swift
import Hyber
```

In  `func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool` add following
```swift
  Hyber.register(
    applicationKey: "Your Global Message Service Key",
    firebaseMessagingHelper: HyberFirebaseMessagingDelegate.sharedInstance,
    launchOptions: launchOptions)
```
This method returns `HyberPushNotification` if remote or local notification was found in passed `launchOptions` parameter, `nil` otherwise, so you can use if like this: `let pushNotification = Hyber.register(...)`

In  `func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)` add following
```swift
  Hyber.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
```

In `func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)` add following
```swift
  Hyber.didReceiveRemoteNotification(userInfo)

  completionHandler(.NewData)
```

#### Register your application for Remote Notification

##### Certificates
Configure push-notifications in [Certificates, Identifiers & Profiles](https://developer.apple.com/account/ios/certificate/certificateList.action) section of Apple Developer Member Center ([manual](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW6))
##### Registering for Remote Notifications
Register your application to receive remote push-notifications ([manual](https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW2))

Don't forget add Push Notifications for your target (see `Capabilities` tab). And add turn on `Background Modes`, whith `Remote Notifications` flag ON)

### Usage
To start using Hyber framework you should provide correct subscriber e-mail & phone (optionally)

#### Subscriber information
##### Add
To add new subscriber you should call
```swift
Hyber.addSubscriber(
  phone: UInt64,
  email: String?,
  completionHandler: ((HyberResult<UInt>) -> Void)? = .None)
```
In completion handler result you will get Hyber subscriber ID if success

##### Edit
To edit subscriber information you should call
```swift
Hyber.updateSubscriberInfo(
  phone: UInt64,
  email: String?,
  completionHandler: ((HyberResult<Void>) -> Void)? = .None)
```
In completion handler result you will get success `Bool` flag

Update subscriber's location
```swift
Hyber.updateSubscriberLocation(
  location: CLLocation?,
  completionHandler: ((HyberResult<Void>) -> Void)? = .None)
```

Update subscriber's changed Firebase Messaging token (managed by `HyberFirebaseMessagingDelegate`)
```swift
Hyber.updateFirebaseMessagingToken(
  token: String?,
  completionHandler: ((HyberResult<Void>) -> Void)? = .None)
```

Update subscriber can receive push-notifications flag (managed by `HyberFirebaseMessagingDelegate`)
```swift
Hyber.allowRecievePush(
  allowPush: Bool,
  completionHandler: ((HyberResult<Void>) -> Void)? = .None)
```

#### Get delivered messages
To fetch delivered messages call
```swift
Hyber.fetchMessages(
  forDate: NSDate,
  completionHandler: ((HyberResult<[HyberMessageData]>) -> Void)? = .None)
```
Example
```swift
let someDate = NSDate()
Hyber.fetchMessages(forDate: someDate) { result in
  guard let messages = result.value else { return }
  // you code goes here
}
```

### How to get keys, push-notifications, IDs

#### Hyber application key
Contact [Global Message Services](http://www.gms-worldwide.com/en/kontakty.html)

#### Firebase Messaging (push-notifications)
Create new project in [Firebase console](https://firebase.google.com/console/).
Add iOS aaplication into your project.
Enable Cloud Messaging API for you project in  Go to project Settings, switch to Cloud Messaging tab. Upload APNs certificates ([Manual](https://firebase.google.com/docs/cloud-messaging/ios/certs)).
Than download `GoogleService-Info.plist` from `General` tab (Firebase console, project settings).
Add this file to yours application project.

### License
[MIT][LICENSE]

#### 3rdparties
[XCGLogger](https://github.com/DaveWoodCom/XCGLogger) by [Dave Wood](https://twitter.com/DaveWoodX). [MIT license](https://github.com/DaveWoodCom/XCGLogger/blob/master/LICENSE.txt)

[Firebase Messaging](https://github.com/google/gcm/blob/master/LICENSE)
[LICENSE]: LICENSE
[HyberFirebaseMessagingDelegateLink]: targetFiles/HyberFirebaseMessagingDelegate.swift
