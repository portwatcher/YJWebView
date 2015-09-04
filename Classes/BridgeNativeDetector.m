//
//  BridgeNativeDetector.m
//  YJWebView
//
//  Created by Jury on 15/9/4.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "BridgeNativeDetector.h"

@implementation BridgeNativeDetector

- (id)init {
    self = [super init];
    if (self) {
        NSString *detectorPath = [[NSBundle mainBundle] pathForResource:@"detector" ofType:@"js"];
        NSString *detectorJS = [NSString stringWithContentsOfFile:detectorPath encoding:NSUTF8StringEncoding error:nil];

        self.javaScriptCode = detectorJS;
    }
    return self;
}

- (void)hashChange:(NSString *)hash {
    SEL selector = NSSelectorFromString(@"hashDidChange:");
    
    if ([self.delegate respondsToSelector:@selector(performSelectorOfWebView:withObject:)]) {
        [self.delegate performSelectorOfWebView:selector withObject:hash];
    }
}

- (NSString *)receiverName {
    return @"Detector";
}

@end
