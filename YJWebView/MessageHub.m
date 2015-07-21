//
//  MessageHub.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "MessageHub.h"
#import "YJWebView.h"

@interface MessageHub ()

@property (strong, nonatomic) YJWebView *webView;

@end

@implementation MessageHub

- (id)initWithWebView:(YJWebView *)webView {
    self = [super init];
    if (self) {
        self.webView = webView;
    }
    return self;
}

- (void)postMessage:(id)message {
    NSDictionary *msg = (NSDictionary *)message;
    [self dispatch:msg];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *msg = (NSDictionary *)message.body;
    [self dispatch:msg];
}

- (void)dispatch:(NSDictionary *)command {
    
}

- (void)callback:(NSString *)callbackId callWithArguments:(NSArray *)arguments {
    
}

@end
