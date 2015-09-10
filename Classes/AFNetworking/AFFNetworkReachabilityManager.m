// AFFNetworkReachabilityManager.m
//
// Copyright (c) 2013-2015 AFFNetworking (http://AFFnetworking.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFFNetworkReachabilityManager.h"

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const AFFNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
NSString * const AFFNetworkingReachabilityNotificationStatusItem = @"AFFNetworkingReachabilityNotificationStatusItem";

typedef void (^AFFNetworkReachabilityStatusBlock)(AFFNetworkReachabilityStatus status);

typedef NS_ENUM(NSUInteger, AFFNetworkReachabilityAssociation) {
    AFFNetworkReachabilityForAddress = 1,
    AFFNetworkReachabilityForAddressPair = 2,
    AFFNetworkReachabilityForName = 3,
};

NSString * AFFStringFromNetworkReachabilityStatus(AFFNetworkReachabilityStatus status) {
    switch (status) {
        case AFFNetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"AFFNetworking", nil);
        case AFFNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"AFFNetworking", nil);
        case AFFNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"AFFNetworking", nil);
        case AFFNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"AFFNetworking", nil);
    }
}

static AFFNetworkReachabilityStatus AFFNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));

    AFFNetworkReachabilityStatus status = AFFNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = AFFNetworkReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = AFFNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = AFFNetworkReachabilityStatusReachableViaWiFi;
    }

    return status;
}

static void AFFNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    AFFNetworkReachabilityStatus status = AFFNetworkReachabilityStatusForFlags(flags);
    AFFNetworkReachabilityStatusBlock block = (__bridge AFFNetworkReachabilityStatusBlock)info;
    if (block) {
        block(status);
    }


    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ AFFNetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:AFFNetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });

}

static const void * AFFNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void AFFNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface AFFNetworkReachabilityManager ()
@property (readwrite, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) AFFNetworkReachabilityAssociation networkReachabilityAssociation;
@property (readwrite, nonatomic, assign) AFFNetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) AFFNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@end

@implementation AFFNetworkReachabilityManager

+ (instancetype)sharedManager {
    static AFFNetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;

        _sharedManager = [self managerForAddress:&address];
    });

    return _sharedManager;
}

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);

    AFFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = AFFNetworkReachabilityForName;

    return manager;
}

+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);

    AFFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = AFFNetworkReachabilityForAddress;

    return manager;
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.networkReachability = reachability;
    self.networkReachabilityStatus = AFFNetworkReachabilityStatusUnknown;

    return self;
}

- (void)dealloc {
    [self stopMonitoring];

    if (_networkReachability) {
        CFRelease(_networkReachability);
        _networkReachability = NULL;
    }
}

#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == AFFNetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == AFFNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    [self stopMonitoring];

    if (!self.networkReachability) {
        return;
    }

    __weak __typeof(self)weakSelf = self;
    AFFNetworkReachabilityStatusBlock callback = ^(AFFNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }

    };

    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, AFFNetworkReachabilityRetainCallback, AFFNetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, AFFNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);

    switch (self.networkReachabilityAssociation) {
        case AFFNetworkReachabilityForName:
            break;
        case AFFNetworkReachabilityForAddress:
        case AFFNetworkReachabilityForAddressPair:
        default: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                SCNetworkReachabilityFlags flags;
                SCNetworkReachabilityGetFlags(self.networkReachability, &flags);
                AFFNetworkReachabilityStatus status = AFFNetworkReachabilityStatusForFlags(flags);
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(status);

                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:AFFNetworkingReachabilityDidChangeNotification object:nil userInfo:@{ AFFNetworkingReachabilityNotificationStatusItem: @(status) }];


                });
            });
        }
            break;
    }
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }

    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString {
    return AFFStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(AFFNetworkReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }

    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
