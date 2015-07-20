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

- (id)initWithFrame:(CGRect)frame {
    if (NSClassFromString(@"WKWebView")) {
        self = (YJWebView *)[[YJWKWebView alloc] initWithFrame:frame];
    } else {
        self = (YJWebView *)[[YJUIWebView alloc] initWithFrame:frame];
    }
    
    return self;
}

- (void)stop {
    
}

- (void)reload {
    
}

- (void)goBack {
    
}

- (void)goForward {
    
}

- (void)insertCSS:(NSString *)css {
    
}

- (void)evaluateJavaScript:(NSString *)js completionHandler:(void (^)())handler {
    
}

@end
