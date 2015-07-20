//
//  LydiaWebView.m
//  LydiaWebView
//
//  Created by Jury on 15/7/17.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "YJWebView.h"

@implementation YJWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (id)webViewWithFrame:(CGRect)frame {
    if (NSClassFromString(@"WKWebView")) {
        return [[YJWKWebView alloc] initWithFrame:frame];
    } else {
        return [[YJUIWebView alloc] initWithFrame:frame];
    }
}

@end
