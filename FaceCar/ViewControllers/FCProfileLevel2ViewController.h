//
//  FCProfileLevel2ViewController.h
//  FC
//
//  Created by facecar on 10/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

@interface FCProfileLevel2ViewController : UITableViewController
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfName;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfEmail;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfBirthDay;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfCMND;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfCmndDate;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfCmndPlace;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UILabel *lblError;

@end
