//
//  BridgeNativeWindow.h
//  Pods
//
//  Created by Jury on 16/2/29.
//
//

#import <Foundation/Foundation.h>
#import "YJHybridBridge.h"

@interface BridgeNativeWindow : NSObject <YJBridgeNative>

@property (strong, nonatomic, readonly) NSString *receiverName;
@property (strong, nonatomic) NSString *javaScriptCode;

@property (weak, nonatomic) id <YJBridgeNativeDelegate> delegate;

- (void)close;

@end
