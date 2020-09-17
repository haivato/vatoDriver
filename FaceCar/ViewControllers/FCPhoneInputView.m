//
//  FCPhoneInputView.m
//  FaceCar
//
//  Created by facecar on 11/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPhoneInputView.h"
#import <PhoneCountryCodePicker/PCCPViewController.h>
#import "FCSmsCodeVerifyView.h"
#import "FCTrackingHelper.h"

#define reachOutOfSmsServiceException @"ReachOutOfSmsServiceException"
#define reachMaxAttemptVerifyAuthenticateException @"ReachMaxAttemptVerifyAuthenticateException"
#define reachMaxRequestAuthenticateException @"ReachMaxRequestAuthenticateException"
#define errorTooManyRequest @"ERROR_TOO_MANY_REQUESTS"

@interface FCPhoneInputView ()
@end

@implementation FCPhoneInputView {
    NSString* _phoneCode;
    BOOL _shouldShowKeyboard;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    _shouldShowKeyboard = YES;
    
    RAC(self.btnNext, enabled) = [RACSignal combineLatest:@[self.tfPhone.rac_textSignal]
                                                   reduce:^(NSString* phone){
//                                                       if (phone.length > 0) {
//                                                           NSString* firstChar = [NSString stringWithFormat:@"%c",[phone characterAtIndex:0]];
//                                                           if (![firstChar isEqualToString:@"0"]) {
//                                                               phone = [NSString stringWithFormat:@"0%@", phone];
//                                                           }
//                                                       }
//
//                                                       if (phone.length == 10) {
//                                                           self.lblError.hidden = YES;
//                                                           return  @(YES);
//                                                       }
                                                       
                                                       return @([self validPhone:phone]);
                                                   }];
    
    //first
    NSDictionary * countryDic = [PCCPViewController infoForPhoneCode:VN_PHONE_CODE];
    _phoneCode = [NSString stringWithFormat:@"+%ld", [[countryDic valueForKey:@"phone_code"] integerValue]];
    self.icFlag.image = [PCCPViewController imageForCountryCode:countryDic[@"country_code"]];
    self.lblCountrycode.text = [NSString stringWithFormat:@"(%@)", _phoneCode];
}

- (void) show {
    [super show];
    
    if (self.loginViewModel.loginType == FCLoginTypeChangePhone) {
        self.lblTitle.text = @"Nhập số điện thoại mới";
    }
}

- (void) willMoveToWindow: (UIWindow*) window {
    [super willMoveToWindow:window];
    if (window && _shouldShowKeyboard) {
        [NSTimer scheduledTimerWithTimeInterval:0.3f
                                         target:self
                                       selector:@selector(onShowKeyboard)
                                       userInfo:nil
                                        repeats:NO];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void) loadSMSCodeView {
    FCSmsCodeVerifyView* smsCodeView = [[FCSmsCodeVerifyView alloc] intView];
    smsCodeView.viewController = self.viewController;
    smsCodeView.loginViewModel = self.loginViewModel;
    [self addSubview:smsCodeView];
    [smsCodeView showNext];
    self.smsCodeView = smsCodeView;
}

- (void) onShowKeyboard {
    [self.tfPhone becomeFirstResponder];
}

- (IBAction)onNextClicked:(id)sender {
    
    [self.loginViewModel setPhoneNumber:self.tfPhone.text
                           andPhoneCode:_phoneCode];
    
    
    if (self.loginViewModel.loginType == FCLoginTypeChangePhone) {
        NSString* phone = [FIRAuth auth].currentUser.phoneNumber;
        phone = [phone stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
        if ([self.loginViewModel.phoneNumber isEqualToString:phone]) {
            self.lblError.hidden = NO;
            self.lblError.text = @"Không thể đổi sang số điện thoại đang sử dụng!";
            [self.btnNext dismissProcess];
            return;
        }
    }
    
    _shouldShowKeyboard = NO;
    self.btnNext.enabled = NO;
    
    // for apply apple review
    if ([self.loginViewModel.phoneNumber isEqualToString:PHONE_TEST]) {
        [self loadSMSCodeView];
        return;
    }
    
    // for normal login
    [self.loginViewModel getSMSPasscode:^(NSError *err) {
        self.btnNext.enabled = YES;
        
        if (err) {
            self.lblError.hidden = NO;
            NSString* errCode;
            if (err.code == FIRAuthErrorCodeInvalidPhoneNumber) {
                self.lblError.text = @"Số điện thoại không đúng.";
                errCode = @"FIRAuthErrorCodeInvalidPhoneNumber";
            }
            else if (err.code == FIRAuthErrorCodeMissingPhoneNumber) {
                self.lblError.text = @"Cung cấp số điện thoại để tiếp tục.";
                errCode = @"FIRAuthErrorCodeMissingPhoneNumber";
            }
            else if (err.code == FIRAuthErrorCodeTooManyRequests) {
                self.lblError.text = @"Bạn đã yêu cầu đăng nhập vượt quá số lần quy định. Vui lòng thử lại sau";
//                self.lblError.text = @"Số điện thoại này đang bị quấy rối. Quay lại sau.";
                errCode = @"FIRAuthErrorCodeTooManyRequests";
            }
            else if ([err.localizedDescription containsString:@"InvalidPhoneNumberFormatException"]) {
                self.lblError.text = @"Số điện thoại không đúng.";
                errCode = @"InvalidPhoneNumberFormatException";
            }
            else if ([err.localizedDescription containsString:@"MustWaitBeforeRequestAnotherVerifyCodeException"]) {
                self.lblError.text = @"Vui lòng thử lại sau giây lát.";
                errCode = @"MustWaitBeforeRequestAnotherVerifyCodeException";
            }
            else {
                NSString *message = @"Xảy ra lỗi. Vui lòng thử lại.";
                if ([self isReachLimitSMS:err]) {
                    message = @"Bạn đã yêu cầu đăng nhập vượt quá số lần quy định. Vui lòng thử lại sau";
                }
                
                self.lblError.text = message;
                errCode = err.localizedDescription;
                if (errCode.length == 0) {
                    errCode = @"FCLoginResultCodeVerifyPhoneUnknowError";
                }
            }
            
            [FCTrackingHelper trackEvent:@"RequestOTP" value:@{@"Service":[[FirebaseHelper shareInstance] getAuthServiceName],
                                                               @"Result":errCode,
                                                               @"Phone":self.tfPhone.text}];
        }
        else {
            [self loadSMSCodeView];
            [FCTrackingHelper trackEvent:@"RequestOTP" value:@{@"Service":[[FirebaseHelper shareInstance] getAuthServiceName],
                                                               @"Result":@"Success",
                                                               @"Phone":self.tfPhone.text}];
        }
        
    }];
}

- (BOOL)isReachLimitSMS:(NSError *)error {
    NSString *msg = [[error localizedDescription] uppercaseString];
    NSString *errorName = [error userInfo][@"error_name"];
    if ([msg containsString:[reachOutOfSmsServiceException uppercaseString]]
        || [msg containsString:[reachMaxAttemptVerifyAuthenticateException uppercaseString]]
        || [msg containsString:[reachMaxRequestAuthenticateException uppercaseString]]
        || [errorName containsString:[errorTooManyRequest uppercaseString]]){
        return YES;
    }
    return NO;
}

- (IBAction)countryClicked:(id)sender {
    /*
    //second
    PCCPViewController * vc = [[PCCPViewController alloc] initWithCompletion:^(id countryDic) {
        self.icFlag.image = [PCCPViewController imageForCountryCode:countryDic[@"country_code"]];
        _phoneCode = [NSString stringWithFormat:@"+%ld", [[countryDic valueForKey:@"phone_code"] integerValue]];
        self.lblCountrycode.text = [NSString stringWithFormat:@"(%@)", _phoneCode];
    }];
    
    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.viewController presentViewController:naviVC animated:YES completion:NULL];
     */
}

- (IBAction)backPressed:(id)sender {
    [self.tfPhone resignFirstResponder];
    [self hide];
}

@end
