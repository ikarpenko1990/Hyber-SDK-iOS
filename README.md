# Hyber SDK for iOS
[![Platform](https://img.shields.io/badge/Platforms-iOS-lightgray.svg)]()
[![Swift version](https://img.shields.io/badge/Swift-3.0.x-orange.svg)]()
[![Release][release-svg]][release-link]
[![Build Status][travis-build-status-svg]][travis-build-status-link]
[![codecov](https://codecov.io/gh/Incuube/Hyber-SDK-iOS/branch/swift-3.0/graph/badge.svg)][codecov-link]

## Installation

Hyber is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
platform :ios, '9.0'

pod 'Hyber'

```
Then, run the following command:

```bash
$ pod install
```

#### Add files
Add [```HyberFirebaseMessagingDelegate.swift```][HyberFirebaseMessagingDelegateLink] file to your project

#### Modify AppDelegate
##### Add ```import``` statement
```swift
import Hyber
```

In  `func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool` add following
```swift
HyberFirebaseMessagingDelegate.sharedInstance.configureFirebaseMessaging()

Hyber.initialise(clientApiKey:"ClientApiKey",
firebaseMessagingHelper: HyberFirebaseMessagingDelegate.sharedInstance, launchOptions: launchOptions)
```

In `func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)` add following
```swift
	Hyber.didReceiveRemoteNotification(userInfo: userInfo)

	completionHandler(.newData)
```

#### Register your application for Remote Notification

##### Certificates
Configure push-notifications in [Certificates, Identifiers & Profiles](https://developer.apple.com/account/ios/certificate/certificateList.action) section of Apple Developer Member Center ([manual](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW6))
##### Registering for Remote Notifications
Register your application to receive remote push-notifications ([manual](https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW2))

Don't forget add Push Notifications for your target (see `Capabilities` tab). And add turn on `Background Modes`, whith `Remote Notifications` flag ON)
Use method for allow push notification
```swift
HyberFirebaseMessagingDelegate.sharedInstance.registerForRemoteNotification()
```

### Usage
To start using Hyber framework you should provide correct subscriber e-mail & phone (optionally)

## Use logger
By default logger enabled
- Disable `HyberLogger` by setting `enabled` to `false`:

```swift
HyberLogger.enabled = false
```
By default HyberLogger print all messages
- Define a minimum level of severity to only print the messages with a greater or equal severity:

```swift
HyberLogger.minLevel = .warning
```

> The severity levels are `trace`, `debug`, `info`, `warning`, and `error`.


#### Subscriber information

#### Add new user
To add new subscriber you should call, phoneNumber is required
```swift
Hyber.registration(phoneId: String, password:String,  completionHandler: { (success) -> Void in
	if success {

	} else {
	//catch errors here
	}
})
```
In completion handler result you will get Hyber sessionData if success


#### Get delivered push's data array
All messages what you get via Hyber push will be saved to local storage.
Import RealmSwift to your header
Example:
```swift
import RealmSwift
//device array
var deviceList : Results<Device>! //RealmObject
	deviceList = realm.objects(Device.self)
//Messages array
var messageList : Results<Message>! //RealmObject
	messageList = realm.objects(Message.self)

let devices = Array(deviceList)
print("Devices: \(devices)")

let array = Array(messageList) //NSArray Object
//Do anything with array

```
#### Load massege history
For Loading message history from Hyber-SDK use method:
Message history list include all channels messages: push/viber/sms
```swift
Hyber.getMessageList(completionHandler: { (success) -> Void in
if success {

   } else {
//catch errors here
	}
})
```
#### Get device's list
For Loading list of registred devices:
Message history list include all channels messages: push/viber/sms
```swift
Hyber.getDeviceList(completionHandler: { (success) -> Void in
  if success {
      
      } else {
//catch errors here
   }
})

```

#### Fetch massege history
Message history list include all channels messages: push/viber/sms

```swift
	Hyber.fetchMessageArea { AnyObject, Error in
   	 	print("responseObject = \(AnyObject); error = \(Error)")
    	return
	}

```

#### Fetch device's list
For fetch list of registred devices:
```swift
 	Hyber.fetchDeviceList { AnyObject, Error in
        print("responseObject = \(AnyObject); error = \(Error)")
        return
    }

```

#### Revoke device
For for revoke old devices call this method:

```swift
 Hyber.revokeDevice(deviceId:[Array] , completionHandler: { (success) -> Void in
        if success {
                          
        } else {
//catch errors here
        }
})

```
#### Sent Callback message
For reply to message use Callback method:
```swift
Hyber.sendMessageCallback(messageId: String, message: String, completionHandler: { (success) -> Void in
	if success {

		} else {
//catch errors here
	}
})
```
## Support information
Project include demo app with all SDK methods.For any question contact [Hyber](http://hyber.io)

### How to get keys, push-notifications, IDs

#### Hyber application key
Contact [Hyber](http://hyber.io)

#### Firebase Messaging (push-notifications)
Create new project in [Firebase console](https://firebase.google.com/console/).
Add iOS aaplication into your project.
Enable Cloud Messaging API for you project in  Go to project Settings, switch to Cloud Messaging tab. Upload APNs certificates ([Manual](https://firebase.google.com/docs/cloud-messaging/ios/certs)).
Than download `GoogleService-Info.plist` from `General` tab (Firebase console, project settings).
Add this file to yours application project.

### License
[MIT](https://github.com/Incuube/Hyber-SDK-iOS/blob/swift-3.0/LICENSE)

#### 3rdparties
[Firebase Messaging](https://github.com/google/gcm/blob/master/LICENSE)
[RXSwift](http://reactivex.io/intro.html)
[RealmSwift](https://realm.io/)
[Alamofire](https://github.com/Alamofire/Alamofire/blob/master/LICENSE)


[codecov-link]: https://codecov.io/gh/Incuube/Hyber-SDK-iOS
[release-svg]: http://github-release-version.herokuapp.com/github/Incuube/Hyber-SDK-iOS/release.svg
[release-link]: https://github.com/Incuube/Hyber-SDK-iOS/releases/latest

[travis-build-status-svg]: https://travis-ci.org/Incuube/Hyber-SDK-iOS.svg?branch=swift-3.0
[travis-build-status-link]: https://travis-ci.org/Incuube/Hyber-SDK-iOS

[HyberFirebaseMessagingDelegateLink]: https://github.com/Incuube/Hyber-SDK-iOS/blob/swift-3.0/Example/Hyber/HyberFirebaseMessagingDelegate.swift
