//
//  FCConfirmTranferMoneyViewController.h
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCTransferMoney.h"
#import "FCHomeViewModel.h"
#import "FCUserInfo.h"
#import "FCBalance.h"

@interface FCConfirmTranferMoneyViewController : UITableViewController

@property (strong, nonatomic) FCBalance* balance;
@property (strong, nonatomic) FCTransferMoney* transfMoney;
@property (strong, nonatomic) FCUserInfo* userInfo;

@end
