//
//  YJWebViewProvider.h
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YJWebViewDelegate, YJBridgeNative;

@protocol YJWebViewProvider <NSObject>

// native support by both uiwebview and wkwebview
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic) BOOL loading;
@property BOOL canGoBack;
@property BOOL canGoForward;

- (void)stopLoading;
- (void)reload;
- (void)goBack;
- (void)goForward;
- (void)loadRequest:(NSURLRequest *)request;

// support by polyfill or us
@property (nonatomic, weak) id <YJWebViewDelegate> webViewDelegate;

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic) BOOL loaded; // main frame done loading

- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier;
- (void)removeCSSWithIdentifier:(NSString *)identifier;
- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler;
- (void)bindNativeReceiver:(NSObject<YJBridgeNative> *)obj;

@end
