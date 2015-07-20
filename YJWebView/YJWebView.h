//
//  LydiaWebView.h
//  LydiaWebView
//
//  Created by Jury on 15/7/17.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJWebViewProvider.h"

@interface YJWebView : UIView <YJWebViewProvider>

+ (id)webViewWithFrame:(CGRect)frame;

@end
