//
//  LinkAlertController.m
//  FaceCar
//
//  Created by Kieu Minh Phu on 5/3/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "LinkAlertController.h"

@interface LinkAlertController ()

@end


@implementation LinkAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.alertView.layer.cornerRadius = 8;
    self.alertView.layer.masksToBounds = YES;
}

#pragma mark - Init

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray<NSString*>*)buttonTitles {
    
    LinkAlertController *alert = (LinkAlertController *)[[UINib nibWithNibName:@"LinkAlertController" bundle:nil] instantiateWithOwner:nil options:nil][0];
    
    alert.titleLabel.text = title;
    alert.messageTextView.text = message;
    alert.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    for (int i = 0; i < buttonTitles.count; i++) {
        NSString* title = [buttonTitles objectAtIndex:i];
        alert.alertButton.tag = i;
        [alert.alertButton setTitle:title forState:UIControlStateNormal];
    }
    
    return alert;
}

- (IBAction)doneShowAgain:(id)sender {
    if ([self.imgCheckbox.image isEqual:[UIImage imageNamed:@"checkbox"]]) {
        [self.imgCheckbox setImage:[UIImage imageNamed:@"uncheckbox"]];
    }
    else {
        [self.imgCheckbox setImage:[UIImage imageNamed:@"checkbox"]];
    }
}

@end
