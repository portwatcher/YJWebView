//
//  BridgeNativeVibrate.h
//  YJWebView
//
//  Created by Jury on 15/7/24.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJHybridBridge.h"

@interface BridgeNativeVibrate : NSObject <YJBridgeNative>

@property (strong, nonatomic, readonly) NSString *receiverName;
@property (strong, nonatomic) NSString *javaScriptCode;

- (void)vibrate;
- (void)vibrate:(NSNumber *)duration;

@end
