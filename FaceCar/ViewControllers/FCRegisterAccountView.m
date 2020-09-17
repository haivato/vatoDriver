//
//  FCRegisterAccountView.m
//  FaceCar
//
//  Created by facecar on 11/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCRegisterAccountView.h"
#import "NSString+Helper.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>
#import "FCZoneTableViewController.h"
#import "FacecarNavigationViewController.h"

@interface FCRegisterAccountView ()
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfFullName;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfEmail;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfZone;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@end


@implementation FCRegisterAccountView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self.tfFullName becomeFirstResponder];
    
    RAC(self.btnNext, enabled) = [RACSignal combineLatest:@[self.tfFullName.rac_textSignal,
                                                            self.tfEmail.rac_textSignal]
                                                   reduce:^(NSString* name, NSString* email){
                                                       if (name.length > 0 && [name wordCount] < 2) {
                                                           self.lblError.text = @"Nhập đầy đủ họ tên của bạn! (tối thiểu 2 chữ)";
                                                       }
                                                       else if (self.tfEmail.text.length > 0 && ![self validEmail:self.tfEmail.text]) {
                                                           self.lblError.text = @"Email không đúng định dạng!";
                                                       }
                                                       else {
                                                           self.lblError.text = EMPTY;
                                                       }
                                                       
                                                       if (email.length > 0)
                                                           return @([self validEmail:email]);
                                                       
                                                       return @([name wordCount] >= 2);
                                                   }];
    
    [RACObserve(self.loginViewModel, resultCode) subscribeNext:^(id x) {
        if (x) {
            if ([x integerValue] == FCLoginResultCodeBackendVerifyFailed) {
                self.lblError.text = @"Xảy ra lỗi xác thực. Bạn vui lòng thử lại sau!";
                self.lblError.hidden = NO;
            }
        }
    }];
}

- (void) loadUserInfo {
    if (self.driver) {
        if (self.driver.user.fullName.length > 0) {
            self.tfFullName.text = self.driver.user.fullName;
            self.tfFullName.userInteractionEnabled = NO;
            self.btnNext.enabled = YES;
        }
        
        if (self.driver.user.email.length > 0) {
            self.tfEmail.text = self.driver.user.email;
            self.tfEmail.userInteractionEnabled = NO;
        }
    }
}

- (void) showNext {
    [super showNext];
    
    if (self.loginViewModel.driver.user.fullName.length > 0) {
        self.tfFullName.text = self.loginViewModel.driver.user.fullName;
    }
}

- (IBAction)backPressed:(id)sender {
    [self hide];
}

- (IBAction)chooseZoneClicked:(id)sender {
    FCZoneTableViewController* vc = [[FCZoneTableViewController alloc] initView];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    [self.viewController presentViewController:navController
                                      animated:TRUE
                                    completion:nil];
    
    [RACObserve(vc, zoneSelected) subscribeNext:^(FCZone* zone) {
        if (zone) {
            self.tfZone.text = zone.name;
            self.loginViewModel.driver.zoneId = zone.id;
        }
    }];
}

- (IBAction)nextClicked:(id)sender {
    
    [IndicatorUtils showWithMessage:@"Đang kiểm tra ..."];
    self.loginViewModel.driver.user.fullName = self.tfFullName.text;
    self.loginViewModel.driver.user.email = self.tfEmail.text;
    
    if (self.isUpdate) {
        [self.loginViewModel updateUserInfo:^(NSError *error) {
            [IndicatorUtils dissmiss];
            if (!error) {
                self.loginViewModel.resultCode = FCLoginResultCodeRegisterAccountCompelted;
            }
            else {
                self.loginViewModel.resultCode = FCLoginResultCodeCreateUserInfoFailed;
            }
        }];
    }
    else {
        [self.loginViewModel createUserInfo:^(NSError* error) {
            [IndicatorUtils dissmiss];
            if (!error) {
                self.loginViewModel.resultCode = FCLoginResultCodeRegisterAccountCompelted;
            }
            else {
                self.loginViewModel.resultCode = FCLoginResultCodeCreateUserInfoFailed;
            }
        }];
    }
}


@end
