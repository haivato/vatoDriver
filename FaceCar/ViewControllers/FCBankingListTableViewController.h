//
//  FCBankingListTableViewController.h
//  FC
//
//  Created by tony on 9/2/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCBanking.h"

@interface FCBankingListTableViewController : UITableViewController
@property (strong,  nonatomic) FCBanking* bankingSelected;
@property (strong,  nonatomic) FCBanking* currentBank;
@end
