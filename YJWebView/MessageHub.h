//
//  MessageHub.h
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageHubProtocol.h"
@import WebKit;
@class YJWebView;

@interface MessageHub : NSObject <MessageHubExport, WKScriptMessageHandler>

- (id)initWithWebView:(YJWebView *)webView;

@end
