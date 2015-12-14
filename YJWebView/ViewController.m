//
//  ViewController.m
//  YJWebView
//
//  Created by Jury on 15/7/20.
//  Copyright (c) 2015年 Tinydust Technonogy Ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    YJWebView *webView = [YJWebViewFactory webViewWithFrame:self.view.bounds];
    webView.webViewDelegate = self;
    [self.view addSubview:webView];

    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.ku6.com/show/YKrEhOxB6mXfzllHnYaQfw...html"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma delegates

- (BOOL)webView:(YJWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request {
    NSLog(@"should start load with request: %@", request.URL);
    return YES;
}

- (void)webViewDidStartLoading:(YJWebView *)webView {
    NSLog(@"did start loading");
}

- (void)webViewMainDocumentDidLoad:(YJWebView *)webView {
    NSLog(@"dom ready");
}

- (void)webViewDidFinishLoad:(YJWebView *)webView {
    NSLog(@"did finish load");
}

- (void)webView:(YJWebView *)webView didHashChange:(NSString *)hash {
    NSLog(@"did hash change to: %@", hash);
}

@end
