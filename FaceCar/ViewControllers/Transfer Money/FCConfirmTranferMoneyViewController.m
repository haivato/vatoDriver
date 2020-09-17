//
//  FCConfirmTranferMoneyViewController.m
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCConfirmTranferMoneyViewController.h"
#import "FCPassCodeView.h"
#import "FCTransferMoneyViewModel.h"

@interface FCConfirmTranferMoneyViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblCash;
@property (weak, nonatomic) IBOutlet UILabel *lblReceverName;
@property (weak, nonatomic) IBOutlet UILabel *lblReveiverPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;

@end

@implementation FCConfirmTranferMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnConfirm.backgroundColor = NewOrangeColor;
    
    self.lblAmount.text = [self formatPrice:self.transfMoney.cash_amount withSeperator:@"."];
    self.lblCash.text = [self formatPrice:self.balance.hardCash];
    
    self.lblReceverName.text = self.userInfo.fullName;
    self.lblReveiverPhone.text = self.transfMoney.mobile;
    
//    [self showPasscodeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)confirmClicked:(id)sender {
    [self showPasscodeView];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showPasscodeView {
    FCPassCodeView* view = [[FCPassCodeView alloc] initView:self];
    view.lblTitle.text = @"Nhập mật khẩu thanh toán";
    view.lblFogotPass.hidden = YES;
    view.btnFogotPass.hidden = YES;
    [view setupView:PasscodeTypeClose];
    [self.navigationController.view addSubview:view];
    
    [RACObserve(view, passcode) subscribeNext:^(NSString* pass) {
        if (pass.length == 6) {
            self.transfMoney.pin = pass;
            [self transferMoneyToVato: view];
        }
    }];
}

- (void) transferMoneyToVato:(FCPassCodeView*) view {
    [IndicatorUtils show];
    [[FCTransferMoneyViewModel shareInstance] apiTranferMoney:self.transfMoney
                                                        block:^(BOOL success) {
                                                            [IndicatorUtils dissmiss];
                                                            [view removeFromSuperview];
                                                            if (success) {
                                                                [self notifySuccess];
                                                            }
                                                        }];
}

- (void) notifySuccess {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TRANSFER_MONEY_COMPLETED
                                                        object:nil];
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Chúc mừng"
                                         message:[NSString stringWithFormat:@"Bạn đã chuyển thành công %@ đến tài khoản %@", [self formatPrice: self.transfMoney.cash_amount], self.transfMoney.mobile]
                               cancelButtonTitle:@"Xong"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            NSArray *array = [self.navigationController viewControllers];
                                            [self.navigationController popToViewController:[array objectAtIndex:1] animated:TRUE];
                                        }];
}

#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 1;
    }
    return 30;
}

@end
