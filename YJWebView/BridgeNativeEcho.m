//
//  BridgeNativeEcho.m
//  YJWebView
//
//  Created by Jury on 15/7/23.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "BridgeNativeEcho.h"

@implementation BridgeNativeEcho

- (void)say:(NSString *)callbackId :(NSString *)string {
    NSLog(@"Hi, I'm walking through YJHybridBridge: %@", string);
    NSLog(@"callbackId: %@", callbackId);
}

- (NSString *)receiverName {
    return @"Echo";
}

@end
