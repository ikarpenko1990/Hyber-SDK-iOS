# Hyber SDK 2.0 for iOS
[![Platform](https://img.shields.io/badge/Platforms-iOS-lightgray.svg)]()
[![Swift version](https://img.shields.io/badge/Swift-3.0.x-orange.svg)]()
[![Release][release-svg]][release-link]

[![Build Status][travis-build-status-svg]][travis-build-status-link]

## Installation

Hyber is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Hyber'
```

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


[release-svg]: http://github-release-version.herokuapp.com/github/Incuube/Hyber-SDK-iOS/release.svg
[release-link]: https://github.com/Incuube/Hyber-SDK-iOS/releases/latest

[travis-build-status-svg]: https://travis-ci.org/Incuube/Hyber-SDK-iOS.svg?branch=swift-3.0
[travis-build-status-link]: https://travis-ci.org/Incuube/Hyber-SDK-iOS
