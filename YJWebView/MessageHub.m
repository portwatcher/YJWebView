//
//  MessageHub.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "MessageHub.h"
#import "YJHybridBridge.h"

@interface MessageHub ()

@property (weak, nonatomic) YJWebView *webView;
@property (strong, nonatomic) NSMapTable *nativeObjects;

@end

@implementation MessageHub

- (id)initWithWebView:(YJWebView *)webView {
    self = [super init];
    if (self) {
        self.webView = webView;
        self.nativeObjects = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    }
    return self;
}

- (void)postMessage:(id)message {
    if ([message isKindOfClass:[NSDictionary class]]) {
        NSDictionary *msg = (NSDictionary *)message;
        [self dispatch:msg];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *msg = (NSDictionary *)message.body;
    [self dispatch:msg];
}

- (void)dispatch:(NSDictionary *)command {
    NSLog(@"receive command from web: %@", command);
    
    NSString *callbackId = command[@"callbackId"];
    NSString *receiver = command[@"receiver"];
    NSString *action = command[@"action"];
    NSArray *arguments = command[@"args"];
    
    NSObject<YJBridgeNative> *obj = [self.nativeObjects objectForKey:receiver];
    
    NSLog(@"receriver: %@", obj);
    
    if (!obj) {
        return;
    }
    
    NSUInteger count = [arguments count];
    while (count--) {
        action = [action stringByAppendingString:@":"];
    }
    
    SEL selector = NSSelectorFromString(action);
    
    if ([obj respondsToSelector:NSSelectorFromString(action)]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:obj];
        
        [invocation setArgument:(__bridge void *)(callbackId) atIndex:2];
        
        for (NSUInteger i = 3; i < arguments.count + 3; i++) {
            [invocation setArgument:(__bridge void *)([arguments objectAtIndex:i - 2]) atIndex:i];
        }
        
        [invocation invoke];
    }
}

- (void)inviteNativeObjectJoin:(NSObject<YJBridgeNative> *)nativeObject {
    if (!nativeObject) {
        return;
    }
    
    [self.nativeObjects setObject:nativeObject forKey:nativeObject.receiverName];
}

- (void)callback:(NSString *)callbackId callWithArguments:(NSArray *)arguements {
    NSString *argsContent = [[arguements valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *js = [NSString stringWithFormat:@"window.webkit.callbackHandlers.invoke(%@, [%@]);", callbackId, argsContent];
    
    [self.webView executeJavaScript:js completionHandler:nil];
}

@end
