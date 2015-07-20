//
//  YJWKWebView.h
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJWebViewDelegate.h"
@import WebKit;

@interface YJWKWebView : WKWebView

@property (nonatomic, assign) id <YJWebViewDelegate> delegate;

//@property (nonatomic, strong) NSURL *url;
@property BOOL isLoading;

- (void)loadURL:(NSURL *)url;

- (void)insertCSS:(NSString *)css;
- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *)) completionHandler;

@end
