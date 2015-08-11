//
//  BridgeNativeScreenOrientation.m
//  YJWebView
//
//  Created by Jury on 15/8/9.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "BridgeNativeScreenOrientation.h"

@interface BridgeNativeScreenOrientation ()

@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

@implementation BridgeNativeScreenOrientation

- (id)init {
    self = [super init];
    if (self) {
        NSString *orientationPath = [[NSBundle mainBundle] pathForResource:@"screenorientation" ofType:@"js"];
        NSString *orientationJS = [NSString stringWithContentsOfFile:orientationPath encoding:NSUTF8StringEncoding error:nil];
        
        self.javaScriptCode = orientationJS;
    }
    return self;
}

- (void)rotateToLandscape {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    self.orientation = UIInterfaceOrientationLandscapeRight;
}

- (void)rotateToPortrait {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    self.orientation = UIInterfaceOrientationPortrait;
}

- (void)unlockOrientation {
    [self rotateToPortrait];
}

- (NSString *)receiverName {
    return @"ScreenOrientation";
}

@end
