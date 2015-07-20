# Goal

Support as many W3C standards as possible, provide non-invasive interfaces for developers.

# How it works

### iOS 7

In iOS 7 we access the UIWebView's JavaScript context through JavaScriptCore framework and bind native object to the context. 

### iOS 8

In iOS 8 we choose WKWebView for performance consideration, and use documented `postMessage` for bridge communication.

By the way, I really hope we can access the JavaScript context of WKWebView too, however, WKWebView is a dependent-process architecture. 

### Consistent API

The LydiaWebView will detect the iOS version automatically, we will use backed WKWebView first and fall back to UIWebView in iOS 7.

Most important, LydiaWebView expose consistent API for developers, you don't have to worry about the iOS version.


# Getting started.

## Installation

In your `Podfile`

```
pod 'LydiaWebView'
```

and `#import 'LydiaWebView.h'`, we are ready to go.

## Demo

```
```

# Standard we support

## Browser API

