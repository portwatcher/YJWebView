# Goal

* Support as many W3C standards as possible.
* provide non-invasive interfaces for developers.
* No compromise for peformance.

# How it works

### iOS 7

In iOS 7 we access the UIWebView's JavaScript context through JavaScriptCore framework and bind native object to the context. 

### iOS 8

In iOS 8 we choose WKWebView for performance consideration, and use documented `postMessage` for bridge communication.

### Consistent API

The YJWebView will detect the iOS version automatically, we will use backed WKWebView first and fall back to UIWebView in iOS 7.

Most important, YJWebView expose consistent API for developers, you don't have to worry about the iOS version.


# Getting started.

## Installation

In your `Podfile`

```
pod 'YJWebView'
```

and `#import 'YJWebViewFactory.h'`, we are ready to go.

## Demo

```
YJWebView *webView = [YJWebViewFactory webViewWithFrame:self.view.bounds];
webView.yjwebViewDelegate = self;
[self.view addSubview:webView];
    
[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
```

## Properties & Methods

## Delegates

# Standard we support

## Browser API

