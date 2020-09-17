//
//  FCPasscodeViewController.m
//  FC
//
//  Created by facecar on 10/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPasscodeViewController.h"
#import <PasscodeView/PasscodeView.h>
#import "APIHelper.h"

@interface FCPasscodeViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet PasscodeView *passcodeView;

@end

@implementation FCPasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Tạo mật khẩu";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_back"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.lblError.hidden = YES;
    self.textField.delegate = self;
    [self.textField becomeFirstResponder];
    
    if (self.currentPasscode.length > 0) {
        self.lblTitle.text = @"XÁC THỰC MẬT KHẨU";
        self.lblDesc.text = @"Mật khẩu phải được giữ bí mật để thực hiện các giao dịch trên tài khoản của bạn.";
        self.lblDesc.textAlignment = NSTextAlignmentCenter;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCancelCreatePIN) name:@"kCancelCreatePIN" object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.textField.text = nil;
    [self.textField becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.textField.text = nil;
}

- (void) onCancelCreatePIN {
    self.currentPasscode = nil;
}

- (void) onBack {
    self.currentPasscode = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCancelCreatePIN" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backPressed:(id)sender {
    self.currentPasscode = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString *fullString = [NSString stringWithFormat:@"%@%@", textField.text, string];
    if ([string isEqualToString:@""]) {
        fullString = [fullString substringToIndex:[fullString length] - 1];
    }
    [self.passcodeView setProgress:fullString.length];
    
    if (self.passcodeView.progress == self.passcodeView.length) {
        if (self.currentPasscode.length == 0) {
            [self loadConfirmPasscode:fullString];
        }
        else {
            if (![self.currentPasscode isEqualToString:fullString]) {
                self.lblError.hidden = NO;
                self.lblError.text = @"Mật khẩu xác thực không khớp.";
            }
            else {
                self.lblError.hidden = YES;
                [self apiCreatePIN];
            }
        }
    }
    
    
    return YES;
}

- (void) loadConfirmPasscode: (NSString*) code {
    self.currentPasscode = code;
//    self.lblTitle.text = @"NHẬP LẠI MẬT KHẨU";
    self.lblDesc.textAlignment = NSTextAlignmentCenter;

    _textField.text = @"";
    [_passcodeView setProgress:0];
    
    FCPasscodeViewController* passView = [[FCPasscodeViewController alloc] initWithNibName:@"FCPasscodeViewController"
                                                                                    bundle:nil];
    passView.delegate = self.delegate;
    [passView setCurrentPasscode:code];
    [self.navigationController pushViewController:passView animated:YES];
}

- (void) apiCreatePIN {
    [IndicatorUtils show];
    NSDictionary* body = @{@"pin": self.currentPasscode};
    [[APIHelper shareInstance] post:API_CREATE_PIN
                               body:body
                           complete:^(FCResponse *response, NSError *e) {
                               [IndicatorUtils dissmiss];
                               if (response.status == APIStatusOK) {
                                   BOOL ok = [(NSNumber*) response.data boolValue];
                                   if (ok) {
                                       [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CREATE_PIN_COMPLETED
                                                                                           object:nil];
//                                       if ([self.delegate performSelector:@selector(onReceivePasscode:)]) {
                                       [self.delegate passcodeViewController:self passcode:self.currentPasscode];
//                                       }

                                       [UIAlertController showAlertInViewController:self
                                                                          withTitle:@"Thông báo"
                                                                            message:@"Chúc mừng bạn đã tạo mật khẩu thanh toán thành công."
                                                                  cancelButtonTitle:@"Đóng"
                                                             destructiveButtonTitle:nil
                                                                  otherButtonTitles:nil
                                                                           tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                                                                                                                              [self.navigationController popToRootViewControllerAnimated:YES];
                                                                           }];
                                   }
                               }
                           }];
}

@end
