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
        self.nativeObjects = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory];
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
//    TODO: translate js value to objc value, may through JavaScriptCore.framework
    NSLog(@"MessageHub: did receive command from web: %@", command);
    
    NSString *callbackId = command[@"callbackId"];
    NSString *receiver = command[@"receiver"];
    NSString *action = command[@"action"];
    NSArray *arguments = command[@"arguments"];
    
//    lets make a brief translation
    if (callbackId == (id)[NSNull null]) {
        callbackId = nil;
    }

    NSObject<YJBridgeNative> *obj = [self.nativeObjects objectForKey:receiver];
    
    if (!obj) {
        return;
    }
    
    if (callbackId) {
        action = [action stringByAppendingString:@":"];
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
        
        NSUInteger preservedCount = 2;
        for (NSUInteger i = preservedCount; i < arguments.count + preservedCount; i++) {
            id argument = [arguments objectAtIndex:i - preservedCount];
//            NSLog(@"MessageHub: argument %zd: %@", i, argument);
            [invocation setArgument:&(argument) atIndex:i];
        }
        
//        约定：最后一个参数为 callbackId，如果 Web 传过来的东西有 callback 的话。
        if (callbackId) {
            NSUInteger argumentIndex = arguments.count + preservedCount;
//            NSLog(@"MessageHub: argument %zd: %@", argumentIndex, callbackId);
            [invocation setArgument:&(callbackId) atIndex:argumentIndex];
        }
        
        [invocation invoke];
    }
}

- (void)inviteNativeObjectJoin:(NSObject<YJBridgeNative> *)nativeObject {
    if (!nativeObject) {
        return;
    }
    
    if ([nativeObject respondsToSelector:@selector(delegate)]) {
        nativeObject.delegate = self;
    }
    
    [self.nativeObjects setObject:nativeObject forKey:nativeObject.receiverName];
}

- (void)callback:(NSString *)callbackId callWithArguments:(NSArray *)arguements {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arguements options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"MessageHub interrupt with error: %@", error.localizedDescription);
        return;
    }
    
    NSString *argsContent = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *js = [NSString stringWithFormat:@"window.cloudbox.callbackHandlers.invoke(%@, %@);", callbackId, argsContent];
    
    [self.webView executeJavaScript:js completionHandler:nil];
}

- (id)performSelectorOfWebView:(SEL)aSelector withObject:(id)object {
    if ([self.webView respondsToSelector:aSelector]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
           id result = [self.webView performSelector:aSelector withObject:object];
        #pragma clang diagnostic pop
        return result;
    }
    
    return nil;
}

@end
