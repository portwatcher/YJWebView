//
//  YJUIWebView.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "YJUIWebView.h"

@implementation YJUIWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scalesPageToFit = YES;
        self.allowsInlineMediaPlayback = YES;
    }
    return self;
}

- (void)loadURL:(NSURL *)url {
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)insertCSS:(NSString *)css {
    
}

- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler {
    [self stringByEvaluatingJavaScriptFromString:js];
    completionHandler(nil, nil);
}

@end
