//
//  MessageHub.h
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageHubProtocol.h"
#import "YJWebView.h"
#import "YJBridgeNative.h"
@import WebKit;

@interface MessageHub : NSObject <MessageHubExport, WKScriptMessageHandler, YJBridgeNativeDelegate>

@property (weak, nonatomic) id<MessageHubDelegate> delegate;

- (id)initWithWebView:(YJWebView *)webView;
- (void)inviteNativeObjectJoin:(NSObject<YJBridgeNative> *)nativeObject;

@end
