//
//  BridgeNativeWindow.m
//  Pods
//
//  Created by Jury on 16/2/29.
//
//

#import "BridgeNativeWindow.h"

@implementation BridgeNativeWindow

- (void)close {
    SEL selector = NSSelectorFromString(@"windowDidClose");
    
    if ([self.delegate respondsToSelector:@selector(performSelectorOfWebView:withObject:)]) {
        [self.delegate performSelectorOfWebView:selector withObject:nil];
    }
}

- (NSString *)javaScriptCode {
    return @"window.close = function () { window.cloudbox.talk(null, 'Window', 'close', []); };";
}

- (NSString *)receiverName {
    return @"Window";
}

@end
