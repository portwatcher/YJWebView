# Features
YJWebView provide non-invasive API for developers with flexible hybrid framework.

* Dom ready and hash change delegate.
* provide unified API with UIWebView backed on iOS 7, WKWebView backed on iOS 8 and above.
* simple native & JS communication.
* simple customization for your own hybrid needs.

# Getting started

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

## Properties

```
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic) BOOL loading;
@property BOOL canGoBack;
@property BOOL canGoForward;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic) BOOL loaded; // main frame done loading

@property (nonatomic, weak) id <YJWebViewDelegate> webViewDelegate;
```

## Methods

```
- (void)stopLoading;
- (void)reload;
- (void)goBack;
- (void)goForward;
- (void)loadRequest:(NSURLRequest *)request;
- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier;
- (void)removeCSSWithIdentifier:(NSString *)identifier;
- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler;
- (void)bindNativeReceiver:(NSObject<YJBridgeNative> *)obj;
```

## YJWebViewDelegate

```
- (void)webViewDidFinishLoad:(YJWebView *)webView;
- (void)webView:(YJWebView *)webView didFailWithError:(NSError *)error;
- (BOOL)webView:(YJWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request;
- (void)webViewDidStartLoading:(YJWebView *)webView;
- (void)webViewDidStopLoading:(YJWebView *)webView;
- (void)webViewDidGetRedirectRequest:(YJWebView *)webView;
- (void)webViewMainDocumentDidLoad:(YJWebView *)webView;
- (void)webView:(YJWebView *)webView didHashChange:(NSString *)hash;
```

## Hybrid demo

### Native file

Create BridgeNativeEcho.h and BridgeNativeEcho.m.  

In your BridgeNativeEcho.h
```
#import <Foundation/Foundation.h>
#import "YJHybridBridge.h"

@interface BridgeNativeEcho : NSObject <YJBridgeNative>

// these two properties must be implemented properly
@property (strong, nonatomic, readonly) NSString *receiverName;
@property (strong, nonatomic) NSString *javaScriptCode;

// native implementation
- (void)say:(NSString *)string;

@end

```

In your BridgeNativeEcho.m
```
#import "BridgeNativeEcho.h"

@implementation BridgeNativeEcho

- (id)init {
    self = [super init];
    if (self) {
        NSString *echoPath = [[NSBundle mainBundle] pathForResource:@"echo" ofType:@"js"];
        NSString *echoJS = [NSString stringWithContentsOfFile:echoPath encoding:NSUTF8StringEncoding error:nil];

        self.javaScriptCode = echoJS;
    }
    return self;
}

- (void)say:(NSString *)string {
    NSLog(@"Hi, I'm walking through YJHybridBridge: %@", string);
}

- (NSString *)receiverName {
    return @"Echo";
}

@end
```

### JS file

Create echo.js in your app's main bundle

```
var echo = {
  say: function ( word ) {
    // callback function, receiverName in the native, method name, arguments
    window.cloudbox.talk( null, 'Echo', 'say', [ word ] );
  }
};

// just for fun
echo.say.toString = function () {
  return 'function () { [not native code] }';
};
```

### Finally

In your viewController or subclassed WebView:

```
[webView bindNativeReceiver:[[BridgeNativeEcho alloc] init]];
```

Now web developers can use your JS API

```
echo.say('hello world');
```

For more info including callback mechanism, please visit [docs]

# Web Standards

* navigator.vibrate
* Notification
* Service Worker
* ES6 Promise

# Who use
* [CloudBox](http://yunji.one)
