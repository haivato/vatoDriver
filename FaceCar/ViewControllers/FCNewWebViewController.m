//
//  FCNewWebViewController.m
//  FC
//
//  Created by facecar on 6/13/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCNewWebViewController.h"
#import "UserDataHelper.h"
#import "FCWarningNofifycationView.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
#import <WebKit/WebKit.h>

@import WebKit;

@interface FCNewWebViewController () <WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet FCProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) WKWebView* wkWebview;
@end

@implementation FCNewWebViewController {
    BOOL _shouldDismiss;
    NSString* _currentUrl;
}

- (instancetype) init {
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.progressView show];
    self.wkWebview = [[WKWebView alloc] init];
    self.wkWebview.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    self.wkWebview.navigationDelegate = self;
    self.wkWebview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.wkWebview];
    self.lblTitle.text = self.title;
    @weakify(self);
    [RACObserve(_wkWebview, loading) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        [x boolValue] ? [self.progressView show] : [self.progressView dismiss];
    }];
}

- (void) showErrorCannotLoadWebview {
    FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] intView];
    view.bgColor = [UIColor whiteColor];
    view.messColor = [UIColor darkGrayColor];
    [view show:self.wkWebview
         image:[UIImage imageNamed:@"notify_noItem"]
         title:nil
       message: @"Đã xảy ra lỗi khi xử lý yêu cầu này.\nVui lòng thử lại sau."];
}

- (void) loadWebview: (NSString*) url {
    _currentUrl = url;
    [self.wkWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void) loadWebviewWithConfigure:(id<TopupLinkConfigureProtocol>) url {
    if (url.auth) {
        [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
            @try {
                NSString* link = [NSString stringWithFormat:@"%@?token=%@", url.url, token];
                NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                [cookieProperties setObject:@"x-access-token" forKey:NSHTTPCookieName];
                [cookieProperties setObject:token forKey:NSHTTPCookieValue];
                
                NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
                [self loadWebview:link];
            }
            @catch (NSException* e) {
                DLog(@"Error: %@", e)
            }
        }];
    }
    else {
        [self loadWebview:url.url];
    }
}

- (IBAction)closeClicked:(id)sender {
    _shouldDismiss = YES;
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - Webview Delegate
- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

- (void) webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showErrorCannotLoadWebview];
}

- (void) webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showErrorCannotLoadWebview];
}

- (void) webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    DLog(@"Request: %@", navigationAction.request.URL);
    decisionHandler(WKNavigationActionPolicyAllow);
    if ([navigationAction.request.URL.absoluteString containsString:@"vato://token-expire"]) {
        if ([_currentUrl containsString:@"&#"]) {
            [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
                NSInteger index = [_currentUrl rangeOfString:@"&#"].location;
                _currentUrl = [_currentUrl substringToIndex:index+2];
                _currentUrl = [NSString stringWithFormat:@"%@%@", _currentUrl, token];
                [self loadWebview:_currentUrl];
            }];
        }
    }
}


- (void) dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (self.presentedViewController || _shouldDismiss) {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

@end
