//
//  YJWebViewDelegate.h
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YJWebViewDelegate <NSObject>

@optional

- (void)didFinishLoad;
- (void)didFaileLoad;
- (void)didStartLoading;
- (void)didStopLoading;
- (void)didGetRedirectRequest;
- (void)mainDocumentDidLoad;

@end
