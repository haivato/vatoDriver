//
//  FCApplyLoginViewController.m
//  FC
//
//  Created by vudang on 5/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCApplyLoginViewController.h"
#import "UIView+Border.h"
#import "AppDelegate.h"

@interface FCApplyLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnPhone;

@end

@implementation FCApplyLoginViewController

- (instancetype) initView {
    self = [self initWithNibName:@"FCApplyLoginViewController" bundle:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.btnPhone borderViewWithColor:[UIColor whiteColor] andRadius:5];
}

- (IBAction)phoneClicked:(id)sender {
    UIAlertController* dialog = [UIAlertController alertControllerWithTitle:@"Nhập số điện thoại"
                                                                    message:@"Cung cấp số điện thoại để đăng nhập đăng ký" preferredStyle:UIAlertControllerStyleAlert];
    [dialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [dialog addAction:[UIAlertAction actionWithTitle:@"Tiếp tục" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([dialog.textFields firstObject].text.length > 0) {
            [self showPassView:[dialog.textFields firstObject].text];
        }
        
        [dialog dismissViewControllerAnimated:YES completion:nil];
    }]];
    [dialog addAction:[UIAlertAction actionWithTitle:@"Huỷ" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [dialog dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void) showPassView: (NSString*) phone {
    UIAlertController* dialog = [UIAlertController alertControllerWithTitle:phone
                                                                    message:@"Cung cấp số mật khẩu để đăng nhập đăng ký" preferredStyle:UIAlertControllerStyleAlert];
    [dialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
    }];
    [dialog addAction:[UIAlertAction actionWithTitle:@"Tiếp tục" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self signin:phone pass:[dialog.textFields firstObject].text];
        [dialog dismissViewControllerAnimated:YES completion:nil];
    }]];
    [dialog addAction:[UIAlertAction actionWithTitle:@"Huỷ" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [dialog dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void) signin: (NSString*) phone pass: (NSString*) pass {
    [IndicatorUtils show];
    
    NSString* email = [NSString stringWithFormat:@"%@@%@", phone, EMAIL];
    FIRAuthCredential* credential = [FIREmailAuthProvider
                                     credentialWithEmail: email
                                     password:pass];
    
    [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        [IndicatorUtils dissmiss];
        FIRUser *user = authResult.user;
        if (user) {
            [[FirebaseHelper shareInstance] getDriver:^(FCDriver * _Nullable driver) {
                if (driver) {
                    [(AppDelegate*)[UIApplication sharedApplication].delegate loadMainView];
                }
                else {
                    [self showMessageBanner:@"Xảy ra lỗi không thể đăng nhập"
                                     status:NO];
                }
            }];
        }
        else {
            [self showMessageBanner:@"Số điện thoại hoặc mật khẩu không đúng"
                             status:NO];
        }
    }];
    
    
}
@end
