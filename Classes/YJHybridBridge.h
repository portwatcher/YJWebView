//
//  YJHybridBridge.h
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJWebView.h"
#import "YJBridgeNative.h"
@import JavaScriptCore;
@import WebKit;

@interface YJHybridBridge : NSObject

+ (YJHybridBridge *)sharedBridge;
- (void)registerWithJavaScriptContext:(JSContext *)context webView:(YJWebView *)webView;
- (void)registerWithUserContentController:(WKUserContentController *)controller webView:(YJWebView *)webView;
- (void)bindNative:(NSObject<YJBridgeNative> *)obj toWebView:(YJWebView *)webView;
- (void)clearForWebView:(YJWebView *)webView;

@end
