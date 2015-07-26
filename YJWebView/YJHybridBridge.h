//
//  YJHybridBridge.h
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJWebView.h"
@import JavaScriptCore;
@import WebKit;

@protocol YJBridgeNativeDelegate <NSObject>

- (void)callback:(NSString *)callbackId callWithArguments:(NSArray *)arguements;

@end

@protocol YJBridgeNative <NSObject>

@required
@property (strong, nonatomic, readonly) NSString *receiverName;
@property (strong, nonatomic) NSString *javaScriptCode;

@optional
@property (weak, nonatomic) id<YJBridgeNativeDelegate> delegate;

@end

@interface YJHybridBridge : NSObject

+ (YJHybridBridge *)sharedBridge;
- (void)registerWithJavaScriptContext:(JSContext *)context webView:(YJWebView *)webView;
- (void)registerWithUserContentController:(WKUserContentController *)controller webView:(YJWebView *)webView;
- (void)bindNative:(NSObject<YJBridgeNative> *)obj toWebView:(YJWebView *)webView;

@end
