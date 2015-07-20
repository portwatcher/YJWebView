//
//  LydiaWebView.h
//  LydiaWebView
//
//  Created by Jury on 15/7/17.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJWebViewProvider.h"

typedef UIView<YJWebViewProvider> YJWebView;

@interface YJWebViewFactory : UIView

+ (YJWebView *)webViewWithFrame:(CGRect)frame;

@end
