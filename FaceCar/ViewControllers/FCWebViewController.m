//
//  FCWebViewController.m
//  FC
//
//  Created by facecar on 5/8/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCWebViewController.h"
#import <WebKit/WebKit.h>
@interface FCWebViewController ()

@property (strong, nonatomic)  WKWebView *webview;
@property(nonatomic, strong) NSTimer *loadingTimer;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) FCWebViewModel* viewModel;

@end

@implementation FCWebViewController

- (instancetype) initViewWithViewModel:(FCWebViewModel *)viewModel {

    self = [self initWithNibName:@"FCWebViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.viewModel = viewModel;
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_webview atIndex:0];
    @weakify(self);
    [RACObserve(self.viewModel, url) subscribeNext:^(id x) {
        @strongify(self);
        if (x)
            [self loadWebview:self.viewModel.url];
    }];
    
    [RACObserve(_webview, loading) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        [x boolValue] ? [self showLoading] : [self dismissLoading];
    }];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self dismissLoading];
}

- (void) loadWebview: (NSString*) url {
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void) showLoading {
    self.progressView.hidden = NO;
    [self startLoadProgressBar];
    self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(startLoadProgressBar) userInfo:nil repeats:TRUE];
}

- (void) dismissLoading {
    [self.loadingTimer invalidate];
    [self.progressView setProgress:0.0 animated:NO];
    self.progressView.hidden = TRUE;
}

- (void) startLoadProgressBar {
    [self.progressView setProgress:0.0 animated:TRUE];
    [UIView animateWithDuration:5 animations:^{
        [self.progressView setProgress:1.0 animated:TRUE];
    } completion:^(BOOL finished) {
        
    }];
}

@end
