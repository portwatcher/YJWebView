//
//  LydiaWebView.h
//  LydiaWebView
//
//  Created by Jury on 15/7/17.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJUIWebView.h"
#import "YJWKWebView.h"

@protocol YJWebViewDelegate <NSObject>

@optional

- (void)didFinishLoad;
- (void)didFaileLoad;
- (void)didStartLoading;
- (void)didStopLoading;
- (void)didGetRedirectRequest;
- (void)mainDocumentDidLoad;

@end

@interface YJWebView : UIView <UIWebViewDelegate, WKNavigationDelegate>

@property (nonatomic, assign) id <YJWebViewDelegate> delegate;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *title;
@property BOOL isLoading;

@property BOOL canGoBack;
@property BOOL canGoForward;

- (void)stop;
- (void)reload;
- (void)goBack;
- (void)goForward;

- (void)insertCSS:(NSString *)css;
- (void)evaluateJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *)) completionHandler;

@end
