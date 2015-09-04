//
//  YJWebViewDelegate.h
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

//@class YJWebView;
#import <Foundation/Foundation.h>

@protocol YJWebViewDelegate <NSObject>

@optional

- (void)webViewDidFinishLoad:(YJWebView *)webView;
- (void)webView:(YJWebView *)webView didFailwithError:(NSError *)error;
- (BOOL)webView:(YJWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request;
- (void)webViewDidStartLoading:(YJWebView *)webView;
- (void)webViewDidStopLoading:(YJWebView *)webView;
- (void)webViewDidGetRedirectRequest:(YJWebView *)webView;
- (void)webViewMainDocumentDidLoad:(YJWebView *)webView;
- (void)webView:(YJWebView *)webView didHashChange:(NSString *)hash;

@end