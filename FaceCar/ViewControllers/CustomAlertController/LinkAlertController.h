//
//  LinkAlertController.h
//  FaceCar
//
//  Created by Kieu Minh Phu on 5/3/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LinkAlertController;

@interface LinkAlertController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *alertButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *alertView;
@property (weak, nonatomic) IBOutlet UIImageView *imgCheckbox;

#pragma mark - Methods

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray<NSString*>*)buttonTitles ;

@end
