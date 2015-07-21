//
//  LydiaWebView.h
//  LydiaWebView
//
//  Created by Jury on 15/7/17.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YJWebViewProvider;

typedef UIView<YJWebViewProvider> YJWebView;

@interface YJWebViewFactory : NSObject

+ (YJWebView *)webViewWithFrame:(CGRect)frame;

@end
