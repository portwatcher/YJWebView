// AFFHTTPRequestOperationManager.m
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

#import <Foundation/Foundation.h>

#import "AFFHTTPRequestOperationManager.h"
#import "AFFHTTPRequestOperation.h"

#import <Availability.h>
#import <Security/Security.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#endif

@interface AFFHTTPRequestOperationManager ()
@property (readwrite, nonatomic, strong) NSURL *baseURL;
@end

@implementation AFFHTTPRequestOperationManager

+ (instancetype)manager {
    return [[self alloc] initWithBaseURL:nil];
}

- (instancetype)init {
    return [self initWithBaseURL:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return nil;
    }

    // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
    if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }

    self.baseURL = url;

    self.requestSerializer = [AFFHTTPRequestSerializer serializer];
    self.responseSerializer = [AFFJSONResponseSerializer serializer];

    self.securityPolicy = [AFFSecurityPolicy defaultPolicy];

    self.reachabilityManager = [AFFNetworkReachabilityManager sharedManager];

    self.operationQueue = [[NSOperationQueue alloc] init];

    self.shouldUseCredentialStorage = YES;

    return self;
}

#pragma mark -

#ifdef _SYSTEMCONFIGURATION_H
#endif

- (void)setRequestSerializer:(AFFHTTPRequestSerializer <AFFURLRequestSerialization> *)requestSerializer {
    NSParameterAssert(requestSerializer);

    _requestSerializer = requestSerializer;
}

- (void)setResponseSerializer:(AFFHTTPResponseSerializer <AFFURLResponseSerialization> *)responseSerializer {
    NSParameterAssert(responseSerializer);

    _responseSerializer = responseSerializer;
}

#pragma mark -

- (AFFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFFHTTPRequestOperation *operation, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }

        return nil;
    }

    return [self HTTPRequestOperationWithRequest:request success:success failure:failure];
}

- (AFFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(AFFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFFHTTPRequestOperation *operation, NSError *error))failure
{
    AFFHTTPRequestOperation *operation = [[AFFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;

    [operation setCompletionBlockWithSuccess:success failure:failure];
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;

    return operation;
}

#pragma mark -

- (AFFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFFHTTPRequestOperation *operation, NSError *error))failure
{
    AFFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"GET" URLString:URLString parameters:parameters success:success failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFFHTTPRequestOperation *)HEAD:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFFHTTPRequestOperation *operation))success
                         failure:(void (^)(AFFHTTPRequestOperation *operation, NSError *error))failure
{
    AFFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"HEAD" URLString:URLString parameters:parameters success:^(AFFHTTPRequestOperation *requestOperation, __unused id responseObject) {
        if (success) {
            success(requestOperation);
        }
    } failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFFHTTPRequestOperation *operation, NSError *error))failure
{
    AFFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"POST" URLString:URLString parameters:parameters success:success failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
       constructingBodyWithBlock:(void (^)(id <AFFMultipartFormData> formData))block
                         success:(void (^)(AFFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFFHTTPRequestOperation *operation, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }

        return nil;
    }

    AFFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFFHTTPRequestOperation *operation, NSError *error))failure
{
    AFFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"PUT" URLString:URLString parameters:parameters success:success failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFFHTTPRequestOperation *)PATCH:(NSString *)URLString
                       parameters:(id)parameters
                          success:(void (^)(AFFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFFHTTPRequestOperation *operation, NSError *error))failure
{
    AFFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"PATCH" URLString:URLString parameters:parameters success:success failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFFHTTPRequestOperation *)DELETE:(NSString *)URLString
                        parameters:(id)parameters
                           success:(void (^)(AFFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFFHTTPRequestOperation *operation, NSError *error))failure
{
    AFFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"DELETE" URLString:URLString parameters:parameters success:success failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, baseURL: %@, operationQueue: %@>", NSStringFromClass([self class]), self, [self.baseURL absoluteString], self.operationQueue];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSURL *baseURL = [decoder decodeObjectForKey:NSStringFromSelector(@selector(baseURL))];

    self = [self initWithBaseURL:baseURL];
    if (!self) {
        return nil;
    }

    self.requestSerializer = [decoder decodeObjectOfClass:[AFFHTTPRequestSerializer class] forKey:NSStringFromSelector(@selector(requestSerializer))];
    self.responseSerializer = [decoder decodeObjectOfClass:[AFFHTTPResponseSerializer class] forKey:NSStringFromSelector(@selector(responseSerializer))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.baseURL forKey:NSStringFromSelector(@selector(baseURL))];
    [coder encodeObject:self.requestSerializer forKey:NSStringFromSelector(@selector(requestSerializer))];
    [coder encodeObject:self.responseSerializer forKey:NSStringFromSelector(@selector(responseSerializer))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    AFFHTTPRequestOperationManager *HTTPClient = [[[self class] allocWithZone:zone] initWithBaseURL:self.baseURL];

    HTTPClient.requestSerializer = [self.requestSerializer copyWithZone:zone];
    HTTPClient.responseSerializer = [self.responseSerializer copyWithZone:zone];

    return HTTPClient;
}

@end
