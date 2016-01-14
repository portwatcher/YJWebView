//
//  YJProcessPool.h
//  YJWebView
//
//  Created by Jury on 15/9/9.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface YJProcessPool : NSObject

@property (strong, nonatomic) WKProcessPool *processPool;

+ (YJProcessPool *)sharedInstance;

@end
