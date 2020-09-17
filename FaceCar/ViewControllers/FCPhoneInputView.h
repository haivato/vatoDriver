//
//  FCPhoneInputView.h
//  FaceCar
//
//  Created by facecar on 11/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCView.h"
#import "FCButtonNext.h"
#import "FCLoginViewModel.h"
#import "FCSmsCodeVerifyView.h"

@interface FCPhoneInputView : FCView

@property (weak, nonatomic) IBOutlet FCButtonNext *btnNext;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UIImageView *icFlag;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *lblCountrycode;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong, nonatomic) FCLoginViewModel* loginViewModel;
@property (strong, nonatomic) FCSmsCodeVerifyView* smsCodeView;

@end
