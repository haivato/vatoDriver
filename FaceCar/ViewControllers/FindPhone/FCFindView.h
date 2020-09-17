//
//  FCRegisterStationView.h
//  FaceCar
//
//  Created by facecar on 9/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCUserInfo.h"

@interface FCFindView : UIView

- (FCFindView*) initView: (UIViewController*) vc;
- (void) setupView;

@property (strong, nonatomic) NSString* phoneNumber;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consHeight;
@property (weak, nonatomic) IBOutlet UIView *bgview;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet FCProgressView *progressView;

@property (strong, nonatomic) FCUserInfo* userInfo;

- (void) removeView;

@end
