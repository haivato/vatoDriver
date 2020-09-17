//
//  FCInputMoneyViewController.m
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCInputMoneyViewController.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>
#import "FCConfirmTranferMoneyViewController.h"
#import "UIView+Border.h"
#import "UIImageView+AFNetworking.h"

#define kSegueConfirmMoney @"kSegueConfirmMoney"
#define kMinimumCashRequire 0
#define kMaximumCashRequire 100000000

@interface FCInputMoneyViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblZalopayId;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfAmount;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UILabel *lblError;

@end

@implementation FCInputMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnContinue.backgroundColor = NewOrangeColor;
    
    [self.imgAvatar circleView:[UIColor clearColor]];
    [self.tfAmount becomeFirstResponder];
    
    [self.imgAvatar setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.userInfo.avatar]]
                          placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]
                                   success:nil
                                   failure:nil];
    [self.lblPhone setText:self.transfMoney.mobile];
    [self.lblName setText:self.userInfo.fullName];
    self.lblZalopayId.text = EMPTY;
    self.lblZalopayId.hidden = YES;
    
    __block NSString* lastPrice;
    RAC(self.btnContinue, enabled) = [RACSignal combineLatest:@[self.tfAmount.rac_textSignal]
                                                       reduce:^(NSString* amount){
                                                           NSInteger amountVal = [self getPrice:amount];
                                                           if (amountVal > kMaximumCashRequire) {
                                                               self.lblError.hidden = NO;
                                                               self.lblError.text = @"Giá trị giao dịch quá lớn.";
                                                               self.tfAmount.text = lastPrice;
                                                               return @NO;
                                                           }
                                                           
                                                           if (amountVal > self.balance.hardCash - kMinimumCashRequire) {
                                                               self.lblError.hidden = NO;
                                                               self.lblError.text = @"Số dư không đủ.";
                                                               return @NO;
                                                           }
                                                           
                                                           if (amountVal < 10000) {
                                                               self.lblError.hidden = NO;
                                                               self.lblError.text = @"Giao dịch tối thiểu 10.000đ.";
                                                               return @NO;
                                                           }
                                                           
                                                           lastPrice = self.tfAmount.text;
                                                           self.lblError.hidden = YES;
                                                           self.transfMoney.cash_amount = amountVal;
                                                           return @YES;
                                                       }];
}


- (IBAction)priceChanged:(UITextField*)textField {
    
    NSInteger price = [self getPrice:textField.text];
    [textField setText:[self formatPrice:price withSeperator:@"."]];
    
    // resize
    [textField adjustsFontSizeToFitWidth];
    [textField invalidateIntrinsicContentSize];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)continueClicked:(id)sender {
    FCConfirmTranferMoneyViewController* des = (FCConfirmTranferMoneyViewController*) [[NavigatorHelper shareInstance] getViewControllerById:@"FCConfirmTranferMoneyViewController" inStoryboard:STORYBOARD_WITHDRAW];
    des.transfMoney = self.transfMoney;
    des.userInfo = self.userInfo;
    des.balance = self.balance;
    [self.navigationController pushViewController:des animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
