//
//  YJProcessPool.m
//  YJWebView
//
//  Created by Jury on 15/9/9.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "YJProcessPool.h"
#import <WebKit/WebKit.h>

@implementation YJProcessPool

+ (YJProcessPool *)sharedInstance {
    static YJProcessPool *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[YJProcessPool alloc] init];
        _sharedInstance.processPool = [[WKProcessPool alloc] init];
    });
    
    return _sharedInstance;
}

@end
