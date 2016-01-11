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
#import "BridgeNativeDetector.h"
#import "YJProcessPool.h"

@interface YJWKWebView ()

@property (strong, nonatomic) NSTimer *_timer;
@property (assign, nonatomic) BOOL domreadyTriggered;

@end

@implementation YJWKWebView
@synthesize _timer;

- (id)initWithFrame:(CGRect)frame {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    configuration.mediaPlaybackRequiresUserAction = YES; // in some cases, mutiple videos play together
    configuration.processPool = [YJProcessPool processPool];
    
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

- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier complectionBlock:(void (^)(void))complectionBlock {
    NSString *stringToEval = [NSString stringWithFormat:@";(function(){if(document.querySelector('#%@')){return;}var styleElement = document.createElement('style');;styleElement.id='%@';styleElement.innerHTML='%@';document.getElementsByTagName('head')[0].appendChild(styleElement);})();", identifier, identifier,  [[css componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""]];
    [self evaluateJavaScript:stringToEval completionHandler:^(id result, NSError *error) {
        
        if (complectionBlock) {
            complectionBlock();
        }
    }];
}

- (void)removeCSSWithIdentifier:(NSString *)identifier {
    [self evaluateJavaScript:[NSString stringWithFormat:@"var _elementInCloudBox = document.querySelector('#%@');if(_elementInCloudBox){_elementInCloudBox.parentNode.removeChild(_elementInCloudBox);}", identifier] completionHandler:nil];
}

- (void)removeCSSWithIdentifier:(NSString *)identifier complectionBlock:(void (^)(void))complectionBlock {
    [self evaluateJavaScript:[NSString stringWithFormat:@"var _elementInCloudBox = document.querySelector('#%@');if(_elementInCloudBox){_elementInCloudBox.parentNode.removeChild(_elementInCloudBox);}", identifier] completionHandler:^(id result, NSError *error) {
        
        if (!error && complectionBlock) {
            complectionBlock();
        }
    }];
}

- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler {
    [self evaluateJavaScript:js completionHandler:completionHandler];
}

- (void)bindNativeReceiver:(NSObject<YJBridgeNative> *)obj {
    [self evaluateJavaScript:obj.javaScriptCode completionHandler:nil];
    [[YJHybridBridge sharedBridge] bindNative:obj toWebView:self];
}

- (void)clearNativeReceivers {
    [[YJHybridBridge sharedBridge] clearForWebView:self];
}

# pragma delegates

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (![self.webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:)]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    NSURL *url = navigationAction.request.URL;
    
    if (![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"] && ![url.absoluteString isEqualToString:@"about:blank"]) {
        if ([self.webViewDelegate webView:self shouldStartLoadWithRequest:navigationAction.request]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([self.webViewDelegate webView:self shouldStartLoadWithRequest:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if ([self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoading:)]) {
        [self.webViewDelegate webViewDidStartLoading:self];
    }
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
    
    if (![self.webViewDelegate respondsToSelector:@selector(webView:didFailWithError:)]) {
        return;
    }
    
    [self.webViewDelegate webView:self didFailWithError:error];
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
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:alertController animated:YES completion:nil];
        });
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^ _Nonnull __strong)(void))completionHandler {
    NSString *hostString = webView.URL.host;
    NSString *sender = [NSString stringWithFormat:@"%@", hostString];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:sender message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];

    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    NSString *hostString = webView.URL.host;
    NSString *sender = [NSString stringWithFormat:@"%@", hostString];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:sender message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];

    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    NSString *hostString = webView.URL.host;
    NSString *sender = [NSString stringWithFormat:@"%@", hostString];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:sender message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

# pragma private

- (void)startInterceptDomReady {
    [self performNativeBinding];
    
    if (![self.webViewDelegate respondsToSelector:@selector(webViewMainDocumentDidLoad:)]) {
        return;
    }
    
    _timer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(interceptDomReady) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
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
    [self bindNativeReceiver:[[BridgeNativeDetector alloc] init]];
}

- (void)hashDidChange:(NSString *)hash {
    if ([self.webViewDelegate respondsToSelector:@selector(webView:didHashChange:)]) {
        [self.webViewDelegate webView:self didHashChange:hash];
    }
}

@end
