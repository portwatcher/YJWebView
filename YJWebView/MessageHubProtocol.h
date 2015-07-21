//
//  MessageHubProtocol.h
//  YJWebView
//
//  Created by Jury on 15/7/21.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;

@protocol MessageHubExport <JSExport>

- (void)postMessage:(id)message;

@end
