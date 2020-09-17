//
//  ViewController.m
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "FacecarNavigationViewController.h"
#import "FCPhoneInputView.h"
#import "UIView+Border.h"
#import <PhoneCountryCodePicker/PCCPViewController.h>
#import "FCRegisterAccountView.h"
#import "FCVivuPrivacyView.h"
#import "APICall.h"
#import "FCTrackingHelper.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginWithPhoneBtn;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLable;

@property (strong, nonatomic) GIDGoogleUser* googleUser;
@property (strong, nonatomic) FIRAuthCredential* authCredential;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hImageView;

@end

@implementation LoginViewController {
    FCPhoneInputView* _phoneView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set raidius button login with phone
    [self.loginWithPhoneBtn borderViewWithColor:[UIColor clearColor] andRadius:self.loginWithPhoneBtn.frame.size.height/2];
    self.loginWithPhoneBtn.backgroundColor = NewOrangeColor;
    
    self.loginViewmodel = [[FCLoginViewModel alloc] init];
    self.loginViewmodel.viewController = self;
    [self registerLoginResultListener];
    
    CGFloat ratio = [[UIScreen mainScreen] bounds].size.width / 375;
    CGFloat h = 400 * ratio;
    _hImageView.constant = h;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[GIDSignIn sharedInstance] signOut];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

#pragma mark - Action Handler

- (IBAction)phoneTouch:(id)sender {
    [self loadPhoneView];
    [FCTrackingHelper trackEvent:@"Login" value:@{@"Channel":@"Phone"}];
}

- (IBAction)didTouchPolicy:(id)sender {
    NSURL *url = [[NSURL alloc] initWithString:@"https://vato.vn/quy-che-hoat-dong-va-dieu-khoan/"];
    [WebVC loadWebOn:self url:url title:@"Quy chế hoạt động và điều khoản"];
}

#pragma mark - View Hander
- (void) loadPhoneView {
    if (_phoneView) {
        return;
    }
    _phoneView = [[FCPhoneInputView alloc] intView];
    _phoneView.viewController = self;
    _phoneView.loginViewModel = self.loginViewmodel;
    [self.view addSubview:_phoneView];
    [_phoneView show:^(BOOL finished) {
        _phoneView = nil;
    }];
}

- (void) loadRegisterView:(FCDriver*) withDriver
                 isUpdate:(BOOL) isUpdate {
    FCRegisterAccountView* registerView = [[FCRegisterAccountView alloc] intView];
    registerView.viewController = self;
    registerView.loginViewModel = self.loginViewmodel;
    registerView.driver = withDriver;
    registerView.isUpdate = isUpdate;
    [self.view addSubview:registerView];
    [registerView showNext];
    [registerView loadUserInfo];
}

- (void) loadPrivacyView {
    [self.view endEditing:YES];
    FCVivuPrivacyView* privacyView = [[FCVivuPrivacyView alloc] intView];
    privacyView.viewController = self;
    privacyView.loginViewModel = self.loginViewmodel;
    [self.view addSubview:privacyView];
    [privacyView showNext];
}

- (void) gotoHome {
    [[FirebaseHelper shareInstance] updateDeviceInfo];
    UIViewController *viewController = [[NavigatorHelper shareInstance]
                                        getViewControllerById:MAIN_VIEW_CONTROLLER
                                        inStoryboard:STORYBOARD_MAIN];
    
    [UIView transitionFromView:self.view
                        toView:viewController.view
                      duration:0.3 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {
        [[UIApplication sharedApplication] keyWindow].rootViewController = viewController;
    }];
    
}

#pragma mark - New Logic (V2) Handler
- (void) registerLoginResultListener {
    [RACObserve(self.loginViewmodel, resultCode) subscribeNext:^(NSNumber* resultcode) {
        if (resultcode) {
            NSInteger code = [resultcode integerValue];
            if (code == FCLoginResultCodeVerifySMSCodeSuccess) {
                [self checkingAccountWithBackend];
            }
            else if (code == FCLoginResultCodeRegisterAccountCompelted) {
                [self loadPrivacyView];
            }
            else if (code == FCLoginResultCodePrivacyAccepted) {
                [self gotoHome];
            }
            else if (code == FCLoginResultCodeSocialLinkedToPhone) {
                [self gotoHome];
            }
            else if (code == FCLoginResultCodeSocialNotLinkedToPhone) {
                [self loadPhoneView];
            }
        }
    }];
}

- (void) checkingAccountWithBackend {
    AutoReceiveTripManager.shared.flagAutoReceiveTripManager = false;
    [self.loginViewmodel apiCheckAccout:^(BOOL success, BOOL isUpdate, FCDriver* driver) {
        if (success) {
            if (driver.user.fullName.length > 0) {
                if (isUpdate) {
                    [self.loginViewmodel apiUpdateAccount:driver
                                                  handler:^(NSError *error) {
                                                      if (!error) {
                                                          [self gotoHome];
                                                      }
                                                      else {
                                                          [self showMessageBanner:@"Xảy ra lỗi, bạn vui lòng liên hệ tổng đài VATO để được hỗ trợ."
                                                                           status:NO];
                                                      }
                                                  }];
                }
                else {
                    [self gotoHome];
                }
            }
            else {
                [self loadRegisterView: driver
                              isUpdate: isUpdate];
            }
        }
        else {
            [self checkUserData];
        }
    }];
}

- (void) checkUserData {
    [self.loginViewmodel checkingUserData:^(FCDriver * driver) {
        if (driver) {
            [self gotoHome];
            [self.loginViewmodel apiCreateAccount:driver
                                          handler:nil];
        }
        else {
            [self loadRegisterView: driver
                          isUpdate: NO];
        }
    }];
}

@end
