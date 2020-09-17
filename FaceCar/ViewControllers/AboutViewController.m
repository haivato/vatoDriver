//
//  AboutViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/2/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "AboutViewController.h"
#import "KYDrawerController.h"

@interface AboutViewController () <UIWebViewDelegate>

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [IndicatorUtils show];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://facecar.vn"]]];
    self.webview.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [IndicatorUtils dissmiss];
}

- (IBAction)menuClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
