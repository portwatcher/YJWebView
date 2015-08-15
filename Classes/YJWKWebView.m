//
//  YJWKWebView.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "YJWKWebView.h"
#import "YJWebView.h"
#import "YJHybridBridge.h"
#import "BridgeNativeEcho.h"
#import "BridgeNativeVibrate.h"
#import "BridgeNativeNotification.h"
#import "BridgeNativeScreenOrientation.h"

@interface YJWKWebView ()

@property (strong, nonatomic) NSTimer *_timer;
@property (assign, nonatomic) BOOL domreadyTriggered;

@end

@implementation YJWKWebView
@synthesize _timer;

- (id)initWithFrame:(CGRect)frame {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    configuration.mediaPlaybackRequiresUserAction = NO;
    
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    configuration.userContentController = controller;
    
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        self.navigationDelegate = self;
        self.UIDelegate = self;
        self.allowsBackForwardNavigationGestures = YES;
        
        [[YJHybridBridge sharedBridge] registerWithUserContentController:self.configuration.userContentController webView:self];

        self.domreadyTriggered = NO;
    }
    return self;
}

# pragma getters

- (BOOL)loaded {
    return !self.isLoading;
}

# pragma methods

- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier {
    NSString *stringToEval = [NSString stringWithFormat:@";(function(){if(document.querySelector('#%@')){return;}var styleElement = document.createElement('style');;styleElement.id='%@';styleElement.innerHTML='%@';document.getElementsByTagName('head')[0].appendChild(styleElement);})();", identifier, identifier,  [[css componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""]];
    [self evaluateJavaScript:stringToEval completionHandler:nil];
}

- (void)removeCSSWithIdentifier:(NSString *)identifier {
    [self evaluateJavaScript:[NSString stringWithFormat:@"var _element = document.querySelector('#%@');if(_element){_element.parentNode.removeChild(_element);}", identifier] completionHandler:nil];
}

- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler {
    [self evaluateJavaScript:js completionHandler:completionHandler];
}

- (void)bindNativeReceiver:(NSObject<YJBridgeNative> *)obj {
    [self evaluateJavaScript:obj.javaScriptCode completionHandler:nil];
    [[YJHybridBridge sharedBridge] bindNative:obj toWebView:self];
}

# pragma delegates

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (![self.webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:)]) {
        //    don't trigger when we've started a new request
        self.domreadyTriggered = YES;
        
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    if ([self.webViewDelegate webView:self shouldStartLoadWithRequest:navigationAction.request]) {
        //    don't trigger when we've started a new request
        self.domreadyTriggered = YES;
        
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    self.domreadyTriggered = NO;
    [self startInterceptDomReady];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (![self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        return;
    }
    
    [self.webViewDelegate webViewDidFinishLoad:self];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (![self.webViewDelegate respondsToSelector:@selector(webView:didFailwithError:)]) {
        return;
    }
    
    [self.webViewDelegate webView:self didFailwithError:error];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSString *hostName = webView.URL.host;
    
    NSString *authenticationMethod = [[challenge protectionSpace] authenticationMethod];
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault]
        || [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]
        || [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {
        
        NSString *title = @"Authentication Challenge";
        NSString *message = [NSString stringWithFormat:@"%@ requires user name and password", hostName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"User";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Password";
            textField.secureTextEntry = YES;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *userName = ((UITextField *)alertController.textFields[0]).text;
            NSString *password = ((UITextField *)alertController.textFields[1]).text;
            
            NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];
            
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:alertController animated:YES completion:^{}];
        });
        
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

# pragma private

- (void)startInterceptDomReady {
    [self performNativeBinding];
    
    if (![self.webViewDelegate respondsToSelector:@selector(webViewMainDocumentDidLoad:)]) {
        return;
    }
    
    _timer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(interceptDomReady) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)interceptDomReady {
    [self evaluateJavaScript:@"document.readyState" completionHandler:^(id result, NSError *error) {
        NSString *readyState = (NSString *)result;

        if ([readyState isEqualToString:@"interactive"] || [readyState isEqualToString:@"complete"]) {
            [_timer invalidate];
            _timer = nil;
            
            if (!self.domreadyTriggered) {
                self.domreadyTriggered = YES;
                
                [self.webViewDelegate webViewMainDocumentDidLoad:self];
            }
        }
    }];
}

- (void)performNativeBinding {
//    [self bindNativeReceiver:[[BridgeNativeEcho alloc] init]];
    [self bindNativeReceiver:[[BridgeNativeVibrate alloc] init]];
    [self bindNativeReceiver:[[BridgeNativeNotification alloc] init]];
    [self bindNativeReceiver:[[BridgeNativeScreenOrientation alloc] init]];
}

@end
