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
    
    YJWebView *webView = [YJWebView webViewWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    
    [webView loadURL:[NSURL URLWithString:@"http://www.baidu.com"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
