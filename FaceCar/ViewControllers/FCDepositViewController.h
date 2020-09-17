//
//  FCDepositViewController.h
//  FC
//
//  Created by facecar on 6/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCSupperViewController.h"
#import "FCWalletViewModel.h"

@interface FCDepositViewController : FCSupperViewController

@property (strong, nonatomic) FCWalletViewModel* walletViewModel;
- (instancetype) initView;

@end
