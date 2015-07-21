//
//  YJUIWebView.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "YJUIWebView.h"
#import <objc/runtime.h>

@interface YJUIWebView ()

@property (nonatomic, strong) JSContext *jsContext;
- (NSString *)documentReadyState;

@end

@implementation YJUIWebView

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

- (void)removeCSSWithIdentifier:(NSString *)identifier {
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var _element = document.querySelector('#%@');if(_element){_element.parentNode.removeChild(_element);}", identifier]];
}

- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler {
    [self stringByEvaluatingJavaScriptFromString:js];
    completionHandler(nil, nil);
}

# pragma delegates

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx {
    self.jsContext = ctx;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([self isDocumentReady]) {
        
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

# pragma private

- (NSString *)documentReadyState {
    return [self stringByEvaluatingJavaScriptFromString:@"document.readyState"];
}

- (BOOL)isDocumentReady {
    return ([self.documentReadyState isEqualToString:@"interactive"] || [self.documentReadyState isEqualToString:@"complete"]);
}

@end
