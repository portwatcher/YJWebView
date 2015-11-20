//
//  YJUIWebView.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "YJUIWebView.h"
#import "YJWebView.h"
#import "YJHybridBridge.h"
#import "BridgeNativeEcho.h"
#import "BridgeNativeVibrate.h"
#import "BridgeNativeNotification.h"
#import "BridgeNativeScreenOrientation.h"
#import "BridgeNativeDetector.h"

@interface YJUIWebView ()

@property (nonatomic, strong) JSContext *jsContext;
@property (assign, nonatomic) BOOL didStartInterceptNewRequest;
@property (strong, nonatomic) NSTimer *_timer;
@property (strong, nonatomic) NSString *selectedImageURL;
@property (strong, nonatomic) NSString *selectedHref;

- (NSString *)documentReadyState;

@end

@implementation YJUIWebView
@synthesize _timer, selectedHref, selectedImageURL;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.scalesPageToFit = YES;
        self.allowsInlineMediaPlayback = YES;
        self.keyboardDisplayRequiresUserAction = NO;
        self.dataDetectorTypes = UIDataDetectorTypeAll;

        self.loaded = NO;
        self.didStartInterceptNewRequest = NO;

        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

# pragma getters

- (NSString *)title {
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (NSURL *)URL {
    return [NSURL URLWithString:[self stringByEvaluatingJavaScriptFromString:@"location.href"]];
}

# pragma methods

- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier {
    NSString *stringToEval = [NSString stringWithFormat:@";(function(){if(document.querySelector('#%@')){return;}var styleElement = document.createElement('style');;styleElement.id='%@';styleElement.innerHTML='%@';document.getElementsByTagName('head')[0].appendChild(styleElement);})();", identifier, identifier,  [[css componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""]];
    [self stringByEvaluatingJavaScriptFromString:stringToEval];
}

- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier complectionBlock:(void (^)(void))complectionBlock {
    NSString *stringToEval = [NSString stringWithFormat:@";(function(){if(document.querySelector('#%@')){return;}var styleElement = document.createElement('style');;styleElement.id='%@';styleElement.innerHTML='%@';document.getElementsByTagName('head')[0].appendChild(styleElement);})();", identifier, identifier,  [[css componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""]];
    [self stringByEvaluatingJavaScriptFromString:stringToEval];

    if (complectionBlock) {
        complectionBlock();
    }
}

- (void)removeCSSWithIdentifier:(NSString *)identifier {
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var _elementInCloudBox = document.querySelector('#%@');if(_elementInCloudBox){_elementInCloudBox.parentNode.removeChild(_elementInCloudBox);}", identifier]];
}

- (void)removeCSSWithIdentifier:(NSString *)identifier complectionBlock:(void (^)(void))complectionBlock {
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var _elementInCloudBox = document.querySelector('#%@');if(_elementInCloudBox){_elementInCloudBox.parentNode.removeChild(_elementInCloudBox);}", identifier]];

    if (complectionBlock) {
        complectionBlock();
    }
}

- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler {
    NSString *result = [self stringByEvaluatingJavaScriptFromString:js];
    
    if (completionHandler) {
        completionHandler(result, nil);
    }
}

- (void)bindNativeReceiver:(NSObject<YJBridgeNative> *)obj {
    [self.jsContext evaluateScript:obj.javaScriptCode];
    [[YJHybridBridge sharedBridge] bindNative:obj toWebView:self];
}

# pragma delegates

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx {
    self.jsContext = ctx;
    [[YJHybridBridge sharedBridge] registerWithJavaScriptContext:self.jsContext webView:self];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (![self.webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:)]) {
        return YES;
    }

    return [self.webViewDelegate webView:self shouldStartLoadWithRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {

    if (!self.didStartInterceptNewRequest) {
        self.didStartInterceptNewRequest = YES;
        [self startInterceptNewPageLoading];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self disableDefaultContextualMenu];

    if ([self isDocumentReady]) {
        [self performNativeBinding];

        self.loaded = YES;

        if (![self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
            return;
        }

        [self.webViewDelegate webViewDidFinishLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (![self.webViewDelegate respondsToSelector:@selector(webView:didFailWithError:)]) {
        return;
    }

    [self.webViewDelegate webView:self didFailWithError:error];
}

# pragma private

- (NSString *)documentReadyState {
    return [self stringByEvaluatingJavaScriptFromString:@"document.readyState"];
}

- (BOOL)isDocumentReady {
    return ([self.documentReadyState isEqualToString:@"interactive"] || [self.documentReadyState isEqualToString:@"complete"]);
}

- (void)startInterceptNewPageLoading {

    if ([self isDocumentReady]) {

        _timer = [NSTimer timerWithTimeInterval:0.05f target:self selector:@selector(interceptNewPageLoading:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    } else {

        [[YJHybridBridge sharedBridge] registerWithJavaScriptContext:self.jsContext webView:self];
        [self performNativeBinding];

        self.didStartInterceptNewRequest = NO;
        if ([self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoading:)]) {
            [self.webViewDelegate webViewDidStartLoading:self];
        }

        [self startInterceptDomReady];
    }
}

- (void)interceptNewPageLoading:(NSTimer *)timer {
    NSString *readyState = [self stringByEvaluatingJavaScriptFromString:@"document.readyState;"];

    if ([readyState isEqualToString:@"loading"]) {
        [timer invalidate];
        timer = nil;

        [[YJHybridBridge sharedBridge] registerWithJavaScriptContext:self.jsContext webView:self];
        [self performNativeBinding];

        self.didStartInterceptNewRequest = NO;
        if ([self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoading:)]) {
            [self.webViewDelegate webViewDidStartLoading:self];
        }

        [self startInterceptDomReady];
    }
}

- (void)startInterceptDomReady {

    if (![self.webViewDelegate respondsToSelector:@selector(webViewMainDocumentDidLoad:)]) {
        return;
    }

    _timer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(interceptDomReady:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)interceptDomReady:(NSTimer *)timer {
    if ([self isDocumentReady]) {
        [timer invalidate];
        timer = nil;

        [self disableDefaultContextualMenu];

        [self.webViewDelegate webViewMainDocumentDidLoad:self];

        NSString *promisePath = [[NSBundle mainBundle] pathForResource:@"es6promise" ofType:@"js"];
        NSString *promiseJS = [NSString stringWithContentsOfFile:promisePath encoding:NSUTF8StringEncoding error:nil];

        [self stringByEvaluatingJavaScriptFromString:promiseJS];
    }
}

- (void)performNativeBinding {
//    [self bindNativeReceiver:[[BridgeNativeEcho alloc] init]];
    [self bindNativeReceiver:[[BridgeNativeVibrate alloc] init]];
    [self bindNativeReceiver:[[BridgeNativeNotification alloc] init]];
    [self bindNativeReceiver:[[BridgeNativeScreenOrientation alloc] init]];
    [self bindNativeReceiver:[[BridgeNativeDetector alloc] init]];
}

- (void)hashDidChange:(NSString *)hash {
    if ([self.webViewDelegate respondsToSelector:@selector(webView:didHashChange:)]) {
        [self.webViewDelegate webView:self didHashChange:hash];
    }
}

- (void)disableDefaultContextualMenu {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"reset" ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    [self.jsContext evaluateScript:js];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    CGPoint coords = [recognizer locationInView:self];

    // get the Tags at the touch location
    NSString *tags = [self stringByEvaluatingJavaScriptFromString:
                      [NSString stringWithFormat:@"window.cloudbox.getHTMLElementsAtPoint(%li,%li);", (long)coords.x, (long)coords.y]];

    NSString *tagsHref = [self stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"window.cloudbox.getLinkHrefAtPoint(%li,%li);", (long)coords.x, (long)coords.y]];
    NSString *tagsSrc = [self stringByEvaluatingJavaScriptFromString:
                         [NSString stringWithFormat:@"window.cloudbox.getLinkSrcAtPoint(%li,%li);", (long)coords.x, (long)coords.y]];
    //    if (![tagsSrc hasPrefix:@"http"] && tagsSrc) {
    //        return;
    //    }

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

    selectedImageURL = @"";
    selectedHref = @"";

    // If a link was touched, add link-related buttons
    if ([tags rangeOfString:@",A," options:NSCaseInsensitiveSearch].location != NSNotFound) {
        selectedHref = tagsHref;

        actionSheet.title = tagsHref;
        [actionSheet addButtonWithTitle:@"复制"];
        [actionSheet addButtonWithTitle:@"打开"];
    }

    // If an image was touched, add image-related buttons.
    if ([tags rangeOfString:@",IMG," options:NSCaseInsensitiveSearch].location != NSNotFound) {
        selectedImageURL = tagsSrc;

        [actionSheet addButtonWithTitle:@"保存图片"];
        [actionSheet addButtonWithTitle:@"复制图片网址"];
    }

    if (actionSheet.numberOfButtons > 0) {
        [actionSheet addButtonWithTitle:@"取消"];
        actionSheet.cancelButtonIndex = (actionSheet.numberOfButtons - 1);
        [actionSheet showInView:self];
    }
}

# pragma mark actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"复制图片网址"]){
        [[UIPasteboard generalPasteboard] setString:selectedImageURL];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"保存图片"]){
        NSOperationQueue *queue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(saveImageToAlbum:) object:selectedImageURL];
        [queue addOperation:operation];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"复制"]) {
        if (selectedHref) {
            [[UIPasteboard generalPasteboard] setString:selectedHref];
        }
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"打开"]) {
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:actionSheet.title]]];
    }
}

#pragma mark save image

- (void)saveImageToAlbum:(NSString *)url {
    [self downloadImageToAlbumFromUrl:url withCallback:^(BOOL succeeded, UIImage *image) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }];
}

- (void)downloadImageToAlbumFromUrl:(NSString *)url withCallback:(void (^)(BOOL succeeded, UIImage *image))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            completionBlock(YES, image);
        } else {
            completionBlock(NO, nil);
        }
    }];
}

@end
