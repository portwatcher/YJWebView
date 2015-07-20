//
//  YJWebViewProvider.h
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJWebViewDelegate.h"

@protocol YJWebViewProvider <NSObject>

@property (nonatomic, weak) id <YJWebViewDelegate> yjwebViewDelegate;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic) BOOL loaded;

@property BOOL canGoBack;
@property BOOL canGoForward;

- (void)stopLoading;
- (void)reload;
- (void)goBack;
- (void)goForward;
- (void)loadRequest:(NSURLRequest *)request;

- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier;
- (void)removeCSSWithIdentifier:(NSString *)identifier;
- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *)) completionHandler;

@end
