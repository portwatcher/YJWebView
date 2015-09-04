//
//  BridgeNativeDetector.h
//  YJWebView
//
//  Created by Jury on 15/9/4.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJHybridBridge.h"

@interface BridgeNativeDetector : NSObject <YJBridgeNative>

@property (strong, nonatomic, readonly) NSString *receiverName;
@property (strong, nonatomic) NSString *javaScriptCode;

@property (weak, nonatomic) id<YJBridgeNativeDelegate> delegate;

- (void)hashChange:(NSString *)hash;

@end
