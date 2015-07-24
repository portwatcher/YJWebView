# Features
YJWebView provide non-invasive API for developers with flexible hybrid framework.

* Dom ready delegate.
* provide unified API with UIWebView backed on iOS 7, WKWebView backed on iOS 8 and above.
* simple native & JS communication.
* simple customization for your own hybrid needs.

# Getting started.

## Installation

In your `Podfile`

```
pod 'YJWebView'
```

and `#import 'YJWebView.h'`, we are ready to go.

## Demo

```
YJWebView *webView = [YJWebViewFactory webViewWithFrame:self.view.bounds];
webView.webViewDelegate = self;
[self.view addSubview:webView];

[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
```

## Properties & Methods

## Delegates

# Standards

## Browser API
* navigator.vibrate
* notification
* service worker
* ES6 promise

# Who use
* (CloudBox)[http://yunji.one]
