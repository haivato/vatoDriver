//
//  ZalopayUpdateViewController.m
//  FC
//
//  Created by facecar on 10/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "ZalopayUpdateViewController.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>
#import "FCPassCodeView.h"
#import "APIHelper.h"

@interface ZalopayUpdateViewController ()

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfZalopayId;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;

@end

@implementation ZalopayUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tfZalopayId becomeFirstResponder];
    
    RAC (self.btnContinue, enabled) = [RACSignal combineLatest:@[self.tfZalopayId.rac_textSignal]
                                                        reduce:^(NSString* zaploay){
                                                            return @(zaploay.length >= 6);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)continueClicked:(id)sender {
    FCPassCodeView* passcodeView = [[FCPassCodeView alloc] initView:self];
    [passcodeView setupView:PasscodeTypeClose];
    passcodeView.consHeight.constant = 400;
    [self.navigationController.view addSubview:passcodeView];
    
    // confirm new pass
    [RACObserve(passcodeView, passcode) subscribeNext:^(NSString* code) {
        if (code.length > 0) {
            [passcodeView removeFromSuperview];
            [self apiUpdateZalopay:code];
        }
    }];
}

- (void) apiUpdateZalopay: (NSString*) pin {
    NSDictionary* body = @{@"paymentType":@(ZALOPAY),
                           @"paymentId": self.tfZalopayId.text,
                           @"pin": pin};
    
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_UPDATE_PAYMENT_CHANNEL
                               body:body
                           complete:^(FCResponse *response, NSError * e) {
                               [IndicatorUtils dissmiss];
                               if (response.status == APIStatusOK) {
                                   [self showMessageBanner:@"Chúc mừng bạn đã cập nhật ZaloPay thành công."
                                                    status:YES];
                                   [self.navigationController popToRootViewControllerAnimated:YES];
                               }
                           }];
}

@end
