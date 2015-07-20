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

@property (nonatomic, weak) id <YJWebViewDelegate> delegate;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *title;
@property BOOL isLoading;

@property BOOL canGoBack;
@property BOOL canGoForward;

- (void)stop;
- (void)reload;
- (void)goBack;
- (void)goForward;
- (void)loadURL:(NSURL *)url;

- (void)insertCSS:(NSString *)css;
- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *)) completionHandler;

@end
