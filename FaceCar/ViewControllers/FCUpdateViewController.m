//
//  FCUpdateViewController.m
//  FaceCar
//
//  Created by facecar on 6/18/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCUpdateViewController.h"
#import "JVFloatLabeledTextField.h"

@interface FCUpdateViewController ()
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfInput;
@property (weak, nonatomic) IBOutlet FCButton *btnUpdate;
@property (weak, nonatomic) IBOutlet UILabel *lblErrorMessage;

@end

@implementation FCUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == UpdateViewTypeEmail) {
        self.tfInput.keyboardType = UIKeyboardTypeEmailAddress;
        self.tfInput.placeholder = @"Email";
        [self.btnUpdate setTitle:@"CẬP NHẬT EMAIL" forState:UIControlStateNormal];
    }
}

- (IBAction)textfieldChanged:(id)sender {
    self.lblErrorMessage.hidden = YES;
}

- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)updateClicked:(id)sender {
    NSString* inputStr = [self.tfInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.type == UpdateViewTypeEmail) {
        inputStr = [inputStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (![self validEmail:inputStr]) {
            self.lblErrorMessage.text = @"Email không đúng định dạng";
            self.lblErrorMessage.hidden = NO;
        }
        else {
            NSString* email = inputStr;
            [IndicatorUtils show];
            [[FirebaseHelper shareInstance] updateUserEmail:email complete:^(NSError *err) {
                [IndicatorUtils dissmiss];
                self.result = email;
                [self closeClicked:nil];
            }];
        }
    }
}

@end
