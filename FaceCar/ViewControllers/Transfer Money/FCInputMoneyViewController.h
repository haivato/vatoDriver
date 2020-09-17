//
//  FCInputMoneyViewController.h
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCTransferMoney.h"
#import "FCUserInfo.h"
#import "FCBalance.h"

@interface FCInputMoneyViewController : UIViewController

@property (strong, nonatomic) FCTransferMoney* transfMoney;
@property (strong, nonatomic) FCUserInfo* userInfo;
@property (strong, nonatomic) FCBalance* balance;

@end
