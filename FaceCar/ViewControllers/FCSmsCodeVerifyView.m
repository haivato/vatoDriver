//
//  FCSmsCodeVerifyView.m
//  FaceCar
//
//  Created by facecar on 11/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCSmsCodeVerifyView.h"
#import "UIView+Border.h"
#import "APICall.h"
#import <SMSVatoAuthen/SMSVatoAuthen-Swift.h>
#import "FCTrackingHelper.h"

//#define TIMEOUT 60

@interface FCSmsCodeVerifyView ()
@property (strong, nonatomic) NSString* resultCode;
@end
    

@implementation FCSmsCodeVerifyView {
    NSInteger _countDown;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    _countDown = (NSInteger)[SMSVatoAuthenInterface retry];
    
    [self onShowKeyboard];
    
    [self startTimeoutResendCode];
    
    [self.btnNext circleView:[UIColor whiteColor]];
}

- (void) showNext {
    [super showNext];
    
    [self loadData];
}

- (void) onShowKeyboard {
    [self.fakeTextfield becomeFirstResponder];
}

- (void) loadData {
    
    self.lblPhone.text = self.loginViewModel.phoneNumber;
    
    RAC(self.btnNext, enabled) = [RACSignal combineLatest:@[self.fakeTextfield.rac_textSignal,
                                                            RACObserve(self.lblError, hidden)]
                                                   reduce:^(NSString* smscode, NSNumber* err){
                                                       return @(smscode.length == 6 || [err boolValue] == NO);
                                                   }];
    
    [self.fakeTextfield.rac_textSignal subscribeNext:^(NSString* text) {
        if (text.length != 6) {
            self.lblError.hidden = YES;
        }
    }];
}

- (void) startTimeoutResendCode {
    [[NSTimer scheduledTimerWithTimeInterval:1
                                      target:self
                                    selector:@selector(onTimeoutResendCode:)
                                    userInfo:nil
                                     repeats:YES] fire];
}

- (void) onTimeoutResendCode: (NSTimer*) timer {
    _countDown --;
    if (_countDown <= 0) {
        [self.lblResendCode setText:[NSString stringWithFormat:@"Gửi lại mã"]];
        [self.lblResendCode setTextColor:[UIColor orangeColor]];
        _countDown = (NSInteger)[SMSVatoAuthenInterface retry];
        [timer invalidate];
        return;
    }
    
    
    [self.lblResendCode setText:[NSString stringWithFormat:@"Gửi lại mã trong %lds", (long)_countDown]];
    [self.lblResendCode setTextColor:[UIColor lightGrayColor]];
    
}

#pragma mark - Process checking
- (void) checkingSMSCode {
    self.btnNext.enabled = NO;
    
    // for apply apple review
    if ([self.loginViewModel.phoneNumber isEqualToString:PHONE_TEST]) {
        if ([_resultCode isEqualToString:PASS_TEST]) {
            self.loginViewModel.smsCode = _resultCode;
            self.loginViewModel.resultCode = FCLoginResultCodeVerifySMSCodeSuccess;
        }
        else {
            self.lblError.hidden = NO;
            self.btnNext.enabled = YES;
            self.lblError.text = @"Xảy ra lỗi, thử lại sau!";
            self.loginViewModel.resultCode = FCLoginResultCodeUnKnow;
        }
        return;
    }
    
    if (self.loginViewModel.loginType == FCLoginTypeSignIn) {
        [self.loginViewModel verifySMSPassCode:_resultCode
                                         block:^(NSError *err) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 self.btnNext.enabled = YES;
                                                 
                                                 if (err) {
                                                     [self showError:err isVerify:YES];
                                                 }
                                                 else {
                                                     self.loginViewModel.resultCode = FCLoginResultCodeVerifySMSCodeSuccess;
                                                     
                                                     [FCTrackingHelper trackEvent:@"VerifyOTP" value:@{@"Service":[[FirebaseHelper shareInstance] getAuthServiceName],
                                                                                                        @"Result":@"Success",
                                                                                                        @"Phone":self.lblPhone.text}];
                                                 }
                                             });
                                         }];
    }
    else {
        self.loginViewModel.smsCode = _resultCode;
        self.loginViewModel.resultCode = FCLoginResultCodeVerifySMSCodeSuccess;
    }
}
    
- (void) showError: (NSError*) err isVerify: (BOOL) verifySMS {
    NSString* errCode;
    if (err.code == FIRAuthErrorCodeSessionExpired) {
        self.lblError.text = @"Mã xác thực hết hạn. Gửi lại mã ngay.";
        self.loginViewModel.resultCode = FCLoginResultCodeVerifySMSCodeExpireSession;
        errCode = @"FIRAuthErrorCodeSessionExpired";
    }
    else if (err.code == FIRAuthErrorCodeInvalidVerificationCode) {
        self.lblError.text = @"Mã xác thực không đúng.";
        self.loginViewModel.resultCode = FCLoginResultCodeVerifySMSCodeInvalid;
        errCode = @"FIRAuthErrorCodeInvalidVerificationCode";
    }
    else if (err.code == FIRAuthErrorCodeCredentialAlreadyInUse) {
        self.lblError.text = @"SDT này đang được sử dụng với một tài khoản khác.";
        errCode = @"FIRAuthErrorCodeCredentialAlreadyInUse";
    }
    else if (err.code == FCLoginResultCodeBackendVerifyFailed) {
        self.lblError.text = @"Tài khoản của bạn gặp sự cố. Vui lòng liên hệ tổng đài để được hỗ trợ.";
        errCode = @"FCLoginResultCodeBackendVerifyFailed";
    }
    else if ([err.localizedDescription containsString:@"InvalidVerifyCodeToVerifyAuthenticateException"]) {
        self.lblError.text = @"Mã xác thực không đúng.";
        errCode = @"InvalidVerifyCodeToVerifyAuthenticateException";
    }
    else if ([err.localizedDescription containsString:@"VerifyCodeTimeOutException"]) {
        self.lblError.text = @"Phiên đăng nhập đã hết hiệu lực.";
        errCode = @"VerifyCodeTimeOutException";
    }
    else {
        self.lblError.text = @"Xảy ra lỗi. Bạn vui lòng kiểm tra và thử lại!";
        self.loginViewModel.resultCode = FCLoginResultCodeVerifySMSCodeUnknowError;
        
        errCode = err.localizedDescription;
        if (errCode.length == 0) {
            errCode = @"FCLoginResultCodeVerifySMSCodeUnknowError";
        }
    }
    
    self.lblError.hidden = NO;
    
    // tracking
    NSString* event;
    if (verifySMS) {
        event = @"VerifyOTP";
    }
    else {
        event = @"RetryOTP";
    }
    [FCTrackingHelper trackEvent:event value:@{@"Service":[[FirebaseHelper shareInstance] getAuthServiceName],
                                                @"Result":errCode,
                                                @"Phone":self.lblPhone.text}];
}

#pragma mark - Action Hander

- (IBAction)backPressed:(id)sender {
    [self hideNext];
    
    [FCTrackingHelper trackEvent:@"BackOTP" value:@{@"Phone":self.lblPhone.text}];
}

- (IBAction)nextClicked:(id)sender {
    [self checkingSMSCode];
}

- (IBAction)codeViewClicked:(id)sender {
    [self.fakeTextfield becomeFirstResponder];
}

- (IBAction)resendCodeClicked:(id)sender {
    if (_countDown != (NSInteger)[SMSVatoAuthenInterface retry]) {
        return;
    }
    
    [self startTimeoutResendCode];
    
    // get smscode
    [SMSVatoAuthenInterface retrySendSMSWithComplete:^(NSString * string) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [FCTrackingHelper trackEvent:@"RetryOTP" value:@{@"Service":[[FirebaseHelper shareInstance] getAuthServiceName],
                                                             @"Result":@"Success",
                                                             @"Phone":self.lblPhone.text}];
        });
        
    } error:^(NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showError:error isVerify:NO];
        });
    }];
}

- (IBAction)codeChanged:(UITextField*)textField {
    if (textField.text.length > 6) {
        textField.text = _resultCode;
        return;
    }
    
    _resultCode = textField.text;
    self.lblCode1.text =
    self.lblCode2.text =
    self.lblCode3.text =
    self.lblCode4.text =
    self.lblCode5.text =
    self.lblCode6.text = EMPTY;
    
    for (int i = 0; i < textField.text.length; i ++) {
        char s = [textField.text characterAtIndex:i];
        switch (i) {
            case 0:
                self.lblCode1.text = [NSString stringWithFormat:@"%c", s];
                break;
            case 1:
                self.lblCode2.text = [NSString stringWithFormat:@"%c", s];
                break;
            case 2:
                self.lblCode3.text = [NSString stringWithFormat:@"%c", s];
                break;
            case 3:
                self.lblCode4.text = [NSString stringWithFormat:@"%c", s];
                break;
            case 4:
                self.lblCode5.text = [NSString stringWithFormat:@"%c", s];
                break;
            case 5:
                self.lblCode6.text = [NSString stringWithFormat:@"%c", s];
                break;
                
            default:
                break;
        }
    }
    
    if (_resultCode.length == 6) {
//        [self checkingSMSCode];
    }
}

@end
