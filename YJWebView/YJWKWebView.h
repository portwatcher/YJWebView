//
//  YJWKWebView.h
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJWebViewProvider.h"
@import WebKit;

@interface YJWKWebView : WKWebView <YJWebViewProvider, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, assign) id <YJWebViewDelegate> webViewDelegate;

@property (nonatomic) BOOL loaded;

- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier;
- (void)removeCSSWithIdentifier:(NSString *)identifier;
- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *)) completionHandler;

@end
