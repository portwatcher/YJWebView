//
//  LydiaWebView.h
//  LydiaWebView
//
//  Created by Jury on 15/7/17.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

@class YJWebView;
#import <UIKit/UIKit.h>

//
@protocol YJWebViewDelegate <NSObject>

@optional

- (void)didFinishLoad:(YJWebView *)webView;
- (void)didFailLoad;
- (void)didStartLoading;
- (void)didStopLoading;
- (void)didGetRedirectRequest;
- (void)mainDocumentDidLoad;

@end

//
@protocol YJWebViewProvider <NSObject>

@property (nonatomic, weak) id <YJWebViewDelegate> webViewDelegate;
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

//
typedef UIView<YJWebViewProvider> YJWebView;

@interface YJWebViewFactory : NSObject

+ (YJWebView *)webViewWithFrame:(CGRect)frame;

@end
