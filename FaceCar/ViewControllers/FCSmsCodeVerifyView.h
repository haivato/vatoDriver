//
//  FCSmsCodeVerifyView.h
//  FaceCar
//
//  Created by facecar on 11/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCView.h"
#import "FCButtonNext.h"
#import "FCLoginViewModel.h"

@interface FCSmsCodeVerifyView : FCView

@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblCode1;
@property (weak, nonatomic) IBOutlet UILabel *lblCode2;
@property (weak, nonatomic) IBOutlet UILabel *lblCode3;
@property (weak, nonatomic) IBOutlet UILabel *lblCode4;
@property (weak, nonatomic) IBOutlet UILabel *lblCode5;
@property (weak, nonatomic) IBOutlet UILabel *lblCode6;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet UILabel *lblResendCode;
@property (weak, nonatomic) IBOutlet FCButtonNext *btnNext;
@property (weak, nonatomic) IBOutlet UITextField *fakeTextfield;
@property (weak, nonatomic) IBOutlet UIView *smsView;

@property (strong, nonatomic) FCLoginViewModel* loginViewModel;

//- (void) showError: (NSError*) err;

@end
