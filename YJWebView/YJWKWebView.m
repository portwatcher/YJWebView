//
//  YJWKWebView.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "YJWKWebView.h"
#import "YJWebView.h"

@implementation YJWKWebView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.navigationDelegate = self;
        self.UIDelegate = self;
        self.configuration.allowsInlineMediaPlayback = YES;
        self.configuration.mediaPlaybackRequiresUserAction = NO;
    }
    return self;
}

# pragma getters

- (BOOL)loaded {
    return !self.loading;
}

# pragma methods

- (void)insertCSS:(NSString *)css withIdentifier:(NSString *)identifier {
    NSString *stringToEval = [NSString stringWithFormat:@";(function(){if(document.querySelector('#%@')){return;}var styleElement = document.createElement('style');;styleElement.id='%@';styleElement.innerHTML='%@';document.getElementsByTagName('head')[0].appendChild(styleElement);})();", identifier, identifier,  [[css componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""]];
    [self evaluateJavaScript:stringToEval completionHandler:nil];
}

- (void)removeCSSWithIdentifier:(NSString *)identifier {
    [self evaluateJavaScript:[NSString stringWithFormat:@"var _element = document.querySelector('#%@');if(_element){_element.parentNode.removeChild(_element);}", identifier] completionHandler:nil];
}

- (void)executeJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completionHandler {
    [self evaluateJavaScript:js completionHandler:completionHandler];
}

# pragma delegates

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

@end
