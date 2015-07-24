//
//  BridgeNativeVibrate.m
//  YJWebView
//
//  Created by Jury on 15/7/24.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "BridgeNativeVibrate.h"
#import <AudioToolbox/AudioServices.h>

@implementation BridgeNativeVibrate

- (id)init {
    self = [super init];
    if (self) {
        NSString *vibrationPath = [[NSBundle mainBundle] pathForResource:@"vibration" ofType:@"js"];
        NSString *vibrationJS = [NSString stringWithContentsOfFile:vibrationPath encoding:NSUTF8StringEncoding error:nil];
        
        self.javaScriptCode = vibrationJS;
    }
    return self;
}

- (void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (NSString *)receiverName {
    return @"Viration";
}

@end
