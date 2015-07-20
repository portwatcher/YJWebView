//
//  YJWKWebView.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "YJWKWebView.h"

@implementation YJWKWebView

- (void)loadURL:(NSURL *)url {
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)insertCSS:(NSString *)css {
    
}

- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler {
    [self evaluateJavaScript:js completionHandler:completionHandler];
}

@end
