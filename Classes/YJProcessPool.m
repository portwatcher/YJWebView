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

+ (WKProcessPool *)processPool {
    static WKProcessPool *_sharedPool = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedPool = [[WKProcessPool alloc] init];
    });
    
    return _sharedPool;
}

@end
