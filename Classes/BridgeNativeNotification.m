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
        self.permissionRequired = NO;
    }
    return self;
}

- (NSString *)receiverName {
    return @"Notification";
}

- (void)show:(NSString *)title :(NSString *)body :(NSString *)iconURLString {
    if (!title || [title isKindOfClass:[NSNull class]]) {
        return;
    }
    
    if ([UIApplication instancesRespondToSelector:NSSelectorFromString(@"registerUserNotificationSettings:")]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    
    if (!body || [body isKindOfClass:[NSNull class]]) {
        body = nil;
    }
    
    if (!iconURLString || [iconURLString isKindOfClass:[NSNull class]]) {
        iconURLString = nil;
    }
    
    if (self.permissionRequired) {
        if ([self.notificationDelegate respondsToSelector:@selector(requestPermissionWithCallback:)]) {
            [self.notificationDelegate requestPermissionWithCallback:^(BOOL granted) {
                if (granted) {
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.alertTitle = title;
                    notification.alertBody = body;
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    notification.fireDate = [NSDate date];
                    
                    if ([self.notificationDelegate respondsToSelector:@selector(arrangeAppearanceOfNotificationWithTitle:body:iconURL:)]) {
                        [self.notificationDelegate arrangeAppearanceOfNotificationWithTitle:title body:body iconURL:[NSURL URLWithString:iconURLString]];
                    } else {
                        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                            if (!body || [body isKindOfClass:[NSNull class]]) {
                                [AGPushNoteView showWithNotificationMessage:[NSString stringWithFormat:@"  %@", title]];
                            } else {
                                [AGPushNoteView showWithNotificationMessage:[NSString stringWithFormat:@"%@: %@", title, body]];
                            }
                        } else {
                            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                        }
                    }
                    
                    self.notification = notification;
                }
            }];
        }
    } else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        if ([notification respondsToSelector:@selector(setAlertTitle:)]) {
            notification.alertTitle = title;
            notification.alertBody = body;
        } else {
            if (!body || [body isKindOfClass:[NSNull class]]) {
                notification.alertBody = [NSString stringWithFormat:@"  %@", title];
            } else {
                notification.alertBody = [NSString stringWithFormat:@"%@: %@", title, body];
            }
        }
        
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.fireDate = [NSDate date];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            if (!body || [body isKindOfClass:[NSNull class]]) {
                [AGPushNoteView showWithNotificationMessage:[NSString stringWithFormat:@"  %@", title]];
            } else {
                [AGPushNoteView showWithNotificationMessage:[NSString stringWithFormat:@"%@: %@", title, body]];
            }
        } else {
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
        
        self.notification = notification;
    }
}

- (void)close {
    if ([self.notificationDelegate respondsToSelector:@selector(arrangeDisappearanceOfNotification)]) {
        [self.notificationDelegate arrangeDisappearanceOfNotification];
    }
    
    [[UIApplication sharedApplication] cancelLocalNotification:self.notification];
    self.notification = nil;
}

- (void)requestPermission:(NSString *)callbackId {
    if (![self.delegate respondsToSelector:@selector(callback:callWithArguments:)]) {
        return;
    }
    
    if (self.permissionRequired) {
        if ([self.notificationDelegate respondsToSelector:@selector(requestPermissionWithCallback:)]) {
            [self.notificationDelegate requestPermissionWithCallback:^(BOOL granted) {
                if (granted) {
                    [self.delegate callback:callbackId callWithArguments:@[@"granted"]];
                } else {
                    [self.delegate callback:callbackId callWithArguments:@[@"denied"]];
                }
            }];
        }
    }
}

@end
