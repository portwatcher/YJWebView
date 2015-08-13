//
//  BridgeNativeNotification.h
//  YJWebView
//
//  Created by Jury on 15/7/26.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJHybridBridge.h"

@protocol YJWebViewNotificationDelegate <NSObject>

- (void)arrangeAppearanceOfNotificationWithTitle:(NSString *)title body:(NSString *)body iconURL:(NSURL *)url;
- (void)arrangeDisappearanceOfNotification;
- (void)requestPermissionWithCallback:(void (^)(BOOL))callback;

@end

@interface BridgeNativeNotification : NSObject <YJBridgeNative>

@property (strong, nonatomic, readonly) NSString *receiverName;
@property (strong, nonatomic) NSString *javaScriptCode;

@property (weak, nonatomic) id<YJBridgeNativeDelegate> delegate;
@property (weak, nonatomic) id<YJWebViewNotificationDelegate> notificationDelegate;

@property BOOL permissionRequired;

- (void)close;
- (void)show:(NSString *)title :(NSString *)body :(NSString *)iconURLString;
- (void)requestPermission:(NSString *)callbackId;

@end
