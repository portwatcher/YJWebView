//
//  YJBridgeNative.h
//  YJWebView
//
//  Created by Jury on 15/7/27.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YJBridgeNativeDelegate <NSObject>

- (void)callback:(NSString *)callbackId callWithArguments:(NSArray *)arguements;
- (id)performSelectorOfWebView:(SEL)aSelector withObject:(id)object;

@end

@protocol YJBridgeNative <NSObject>

@required
@property (strong, nonatomic, readonly) NSString *receiverName;
@property (strong, nonatomic) NSString *javaScriptCode;

@optional
@property (weak, nonatomic) id<YJBridgeNativeDelegate> delegate;

@end

