//
//  YJHybridBridge.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "YJHybridBridge.h"
#import "MessageHub.h"

@interface YJHybridBridge ()

@property (strong, nonatomic) NSString *messageHubJS;
@property (strong, nonatomic) NSString *callbackManagerJS;

@end

@implementation YJHybridBridge

+ (YJHybridBridge *)sharedBridge {
    static YJHybridBridge *_sharedBridge = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedBridge = [[YJHybridBridge alloc] init];
        
        NSString *hubPath = [[NSBundle mainBundle] pathForResource:@"message_hub" ofType:@"js"];
        _sharedBridge.messageHubJS = [NSString stringWithContentsOfFile:hubPath encoding:NSUTF8StringEncoding error:nil];
        
        NSString *callbackManagerPath = [[NSBundle mainBundle] pathForResource:@"callback_manager" ofType:@"js"];
        _sharedBridge.callbackManagerJS = [NSString stringWithContentsOfFile:callbackManagerPath encoding:NSUTF8StringEncoding error:nil];
    });
    
    return _sharedBridge;
}

- (void)registerWithJavaScriptContext:(JSContext *)context webView:(YJWebView *)webView {
    [webView executeJavaScript:self.messageHubJS completionHandler:nil];
    [webView executeJavaScript:self.callbackManagerJS completionHandler:nil];
    
    context[@"window"][@"webkit"][@"messageHandlers"][@"hub"] = [[MessageHub alloc] initWithWebView:webView];
}

- (void)registerWithUserContentController:(WKUserContentController *)controller webView:(YJWebView *)webView {
    [webView executeJavaScript:self.callbackManagerJS completionHandler:nil];
    
    [controller addScriptMessageHandler:[[MessageHub alloc] initWithWebView:webView] name:@"hub"];
}

@end
