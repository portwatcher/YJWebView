//
//  BridgeNativeEcho.m
//  YJWebView
//
//  Created by Jury on 15/7/23.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

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

- (void)say:(NSString *)string :(NSString *)callbackId {
    NSLog(@"callbackId: %@", callbackId);
}

- (NSString *)receiverName {
    return @"Echo";
}

@end
