//
//  FCBankingWithdrawViewController.h
//  FC
//
//  Created by tony on 8/30/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCBankingInfo.h"
#import "FCBanking.h"

@interface FCBankingWithdrawViewController : UITableViewController
@property (strong, nonatomic) FCBankingInfo* bankingInfo;
@property (strong, nonatomic) FCBanking* banking;
@property (assign, nonatomic) NSInteger userCash;

@end
