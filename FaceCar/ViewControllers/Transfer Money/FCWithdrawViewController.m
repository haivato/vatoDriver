//
//  FCWithdrawViewController.m
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCWithdrawViewController.h"
#import "FCInputPhoneViewController.h"
#import "FCInputMoneyViewController.h"
#import "ZalopayUpdateViewController.h"

#define kSegueTransferMoneyToVivu @"kSegueTransferMoneyToVivu"
#define kSegueTransferMoneyToZalo @"kSegueTransferMoneyToZalo"

@interface FCWithdrawViewController ()
@property (strong, nonatomic) FCTransferMoney* transfMoney;
@end

@implementation FCWithdrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.transfMoney = [[FCTransferMoney alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueTransferMoneyToVivu]) {
        FCInputPhoneViewController* des = [segue destinationViewController];
        des.balance = self.balance;
        des.transfMoney = self.transfMoney;
    }
    else if ([segue.identifier isEqualToString:kSegueTransferMoneyToZalo]) {
        FCInputMoneyViewController* des = [segue destinationViewController];
        des.balance = self.balance;
        des.transfMoney = self.transfMoney;
    }
}

- (IBAction)zaloPayClicked:(id)sender {
}

#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![FirebaseHelper shareInstance].appConfigs.zalopayEnable && indexPath.row == 1)
        return 0;
    
    if (indexPath.row == 0 || indexPath.row == 1)
        return 65;
    
    if (indexPath.row == 2) {
        return 300;
    }
    
    return 120;
}

@end
