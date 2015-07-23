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
@property (strong, nonatomic) NSMapTable *hubs;

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

        _sharedBridge.hubs = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory];
    });
    
    return _sharedBridge;
}

- (void)registerWithJavaScriptContext:(JSContext *)context webView:(YJWebView *)webView {
    [webView executeJavaScript:self.messageHubJS completionHandler:nil];
    
    MessageHub *hub = [[MessageHub alloc] initWithWebView:webView];
    
    context[@"window"][@"webkit"][@"messageHandlers"][@"hub"] = hub;
    [webView executeJavaScript:self.callbackManagerJS completionHandler:nil];
    
//    use the memory address as the key
    [self.hubs setObject:hub forKey:[NSString stringWithFormat:@"%p", webView]];
}

- (void)registerWithUserContentController:(WKUserContentController *)controller webView:(YJWebView *)webView {
    MessageHub *hub = [[MessageHub alloc] initWithWebView:webView];
    
    [controller addScriptMessageHandler:hub name:@"hub"];
    [webView executeJavaScript:self.callbackManagerJS completionHandler:nil];
    
//    use the memory address as the key
    [self.hubs setObject:hub forKey:[NSString stringWithFormat:@"%p", webView]];
}

- (void)bindNative:(NSObject<YJBridgeNative> *)obj toWebView:(YJWebView *)webView {
    MessageHub *hub = [self.hubs objectForKey:[NSString stringWithFormat:@"%p", webView]];
    
    if (!hub) {
        return;
    }
    
    [hub inviteNativeObjectJoin:obj];
}

@end
