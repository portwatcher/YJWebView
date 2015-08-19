//
//  YJUIWebView.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "YJUIWebView.h"
#import "YJWebView.h"
#import "YJHybridBridge.h"
#import "BridgeNativeEcho.h"
#import "BridgeNativeVibrate.h"
#import "BridgeNativeNotification.h"
#import "BridgeNativeScreenOrientation.h"

@interface YJUIWebView ()

@property (nonatomic, strong) JSContext *jsContext;
@property (assign, nonatomic) BOOL didStartInterceptNewRequest;
@property (strong, nonatomic) NSTimer *_timer;

- (NSString *)documentReadyState;

@end

@implementation YJUIWebView
@synthesize _timer;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.scalesPageToFit = YES;
        self.allowsInlineMediaPlayback = YES;
        self.keyboardDisplayRequiresUserAction = NO;
        
        self.loaded = NO;
        self.didStartInterceptNewRequest = NO;
    }
    return self;
}

# pragma getters

- (NSString *)title {
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (NSURL *)URL {
    return [NSURL URLWithString:[self stringByEvaluatingJavaScriptFromString:@"location.href"]];
}

# pragma methods

- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier {
    NSString *stringToEval = [NSString stringWithFormat:@";(function(){if(document.querySelector('#%@')){return;}var styleElement = document.createElement('style');;styleElement.id='%@';styleElement.innerHTML='%@';document.getElementsByTagName('head')[0].appendChild(styleElement);})();", identifier, identifier,  [[css componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""]];
    [self.jsContext evaluateScript:stringToEval];
}

- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier complectionBlock:(void (^)(void))complectionBlock {
    NSString *stringToEval = [NSString stringWithFormat:@";(function(){if(document.querySelector('#%@')){return;}var styleElement = document.createElement('style');;styleElement.id='%@';styleElement.innerHTML='%@';document.getElementsByTagName('head')[0].appendChild(styleElement);})();", identifier, identifier,  [[css componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""]];
    [self stringByEvaluatingJavaScriptFromString:stringToEval];
    complectionBlock();
}

- (void)removeCSSWithIdentifier:(NSString *)identifier {
    [self.jsContext evaluateScript:[NSString stringWithFormat:@"var _elementInCloudBox = document.querySelector('#%@');if(_element){_element.parentNode.removeChild(_element);}", identifier]];
}

- (void)removeCSSWithIdentifier:(NSString *)identifier complectionBlock:(void (^)(void))complectionBlock {
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var _elementInCloudBox = document.querySelector('#%@');if(_element){_element.parentNode.removeChild(_element);}", identifier]];
    complectionBlock();
}

- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler {
    if (completionHandler) {
        NSString *result = [self stringByEvaluatingJavaScriptFromString:js];
        completionHandler(result, nil);
    } else {
        [self.jsContext evaluateScript:js];
    }
}

- (void)bindNativeReceiver:(NSObject<YJBridgeNative> *)obj {
    [self.jsContext evaluateScript:obj.javaScriptCode];
    [[YJHybridBridge sharedBridge] bindNative:obj toWebView:self];
}

# pragma delegates

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx {
    self.jsContext = ctx;
    [[YJHybridBridge sharedBridge] registerWithJavaScriptContext:self.jsContext webView:self];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (![self.webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:)]) {
        return YES;
    }
    
    return [self.webViewDelegate webView:self shouldStartLoadWithRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (!self.didStartInterceptNewRequest) {
        self.didStartInterceptNewRequest = YES;
        [self startInterceptNewPageLoading];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([self.documentReadyState isEqualToString:@"complete"]) {
        [self performNativeBinding];
        
        self.loaded = YES;
        
        if (![self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
            return;
        }
        
        [self.webViewDelegate webViewDidFinishLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (![self.webViewDelegate respondsToSelector:@selector(webView:didFailwithError:)]) {
        return;
    }
    
    [self.webViewDelegate webView:self didFailwithError:error];
}

# pragma private

- (NSString *)documentReadyState {
    return [self stringByEvaluatingJavaScriptFromString:@"document.readyState"];
}

- (BOOL)isDocumentReady {
    return ([self.documentReadyState isEqualToString:@"interactive"] || [self.documentReadyState isEqualToString:@"complete"]);
}

- (void)startInterceptNewPageLoading {
    _timer = [NSTimer timerWithTimeInterval:0.05f target:self selector:@selector(interceptNewPageLoading:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)interceptNewPageLoading:(NSTimer *)timer {
    NSString *readyState = [self stringByEvaluatingJavaScriptFromString:@"document.readyState;"];
    
    if ([readyState isEqualToString:@"loading"]) {
        [timer invalidate];
        timer = nil;
        
        [[YJHybridBridge sharedBridge] registerWithJavaScriptContext:self.jsContext webView:self];
        [self performNativeBinding];
        
        if ([self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
            [self.webViewDelegate webViewDidStartLoading:self];
        }
        
        [self startInterceptDomReady];
    }
}

- (void)startInterceptDomReady {
    if (![self.webViewDelegate respondsToSelector:@selector(webViewMainDocumentDidLoad:)]) {
        return;
    }
    
    _timer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(interceptDomReady:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)interceptDomReady:(NSTimer *)timer {
    if ([self isDocumentReady]) {
        [timer invalidate];
        timer = nil;
        
        [self.webViewDelegate webViewMainDocumentDidLoad:self];

        NSString *promisePath = [[NSBundle mainBundle] pathForResource:@"es6promise" ofType:@"js"];
        NSString *promiseJS = [NSString stringWithContentsOfFile:promisePath encoding:NSUTF8StringEncoding error:nil];
        
        [self stringByEvaluatingJavaScriptFromString:promiseJS];
    }
}

- (void)performNativeBinding {
    [self bindNativeReceiver:[[BridgeNativeEcho alloc] init]];
    [self bindNativeReceiver:[[BridgeNativeVibrate alloc] init]];
    [self bindNativeReceiver:[[BridgeNativeNotification alloc] init]];
    [self bindNativeReceiver:[[BridgeNativeScreenOrientation alloc] init]];
}

@end
