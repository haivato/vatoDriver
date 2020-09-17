//
//  FCInputPhoneViewController.h
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"
#import "FCTransferMoney.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>
#import "FCBalance.h"

@interface FCInputPhoneViewController : UIViewController

@property (strong, nonatomic) FCBalance* balance;
@property (strong, nonatomic) FCTransferMoney* transfMoney;

@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;

@end
