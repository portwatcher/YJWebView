//
//  BridgeNativeNotification.m
//  YJWebView
//
//  Created by Jury on 15/7/26.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "BridgeNativeNotification.h"
#import "MessageHub.h"

@implementation BridgeNativeNotification

- (id)init {
    self = [super init];
    if (self) {
        NSString *notificationPath = [[NSBundle mainBundle] pathForResource:@"notification" ofType:@"js"];
        NSString *notificationJS = [NSString stringWithContentsOfFile:notificationPath encoding:NSUTF8StringEncoding error:nil];
        
        self.javaScriptCode = notificationJS;
    }
    return self;
}

- (NSString *)receiverName {
    return @"Notification";
}

- (void)show {
    
}

- (void)close {
    
}

- (void)requestPermission:(NSString *)callbackId {
    if ([self.delegate respondsToSelector:@selector(callback:callWithArguments:)]) {
        [self.delegate callback:callbackId callWithArguments:@[@"granted"]];
    }
}

@end
