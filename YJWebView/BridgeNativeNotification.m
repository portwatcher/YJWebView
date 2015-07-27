//
//  BridgeNativeNotification.m
//  YJWebView
//
//  Created by Jury on 15/7/26.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "BridgeNativeNotification.h"
#import "MessageHub.h"
#import "AGPushNoteView.h"

@interface BridgeNativeNotification ()

@property (strong, nonatomic) UILocalNotification *notification;

@end

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

- (void)show:(NSString *)title :(NSString *)body :(NSString *)iconURLString {
    if ([UIApplication instancesRespondToSelector:NSSelectorFromString(@"registerUserNotificationSettings:")]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertTitle = title;
    notification.alertBody = body;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.fireDate = [NSDate date];
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [AGPushNoteView showWithNotificationMessage:[NSString stringWithFormat:@"%@: %@", title, body]];
    } else {
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    self.notification = notification;
}

- (void)close {
    [[UIApplication sharedApplication] cancelLocalNotification:self.notification];
    self.notification = nil;
}

- (void)requestPermission:(NSString *)callbackId {
    if ([self.delegate respondsToSelector:@selector(callback:callWithArguments:)]) {
        [self.delegate callback:callbackId callWithArguments:@[@"granted"]];
    }
}

@end
