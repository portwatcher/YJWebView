//
//  BridgeNativeScreenOrientation.h
//  YJWebView
//
//  Created by Jury on 15/8/9.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJHybridBridge.h"

@interface BridgeNativeScreenOrientation : NSObject <YJBridgeNative>

@property (strong, nonatomic, readonly) NSString *receiverName;
@property (strong, nonatomic) NSString *javaScriptCode;

- (void)rotateToLandscape;
- (void)rotateToPortrait;
- (void)unlockOrientation;

@end
