//
//  FCVivuPrivacyView.m
//  FaceCar
//
//  Created by facecar on 11/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCVivuPrivacyView.h"
#import "FacecarNavigationViewController.h"
#import "FCWebViewController.h"

@interface FCVivuPrivacyView ()
@property (weak, nonatomic) IBOutlet FCButtonNext *btnNext;
@end


@implementation FCVivuPrivacyView

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (void) willMoveToWindow: (UIWindow*) window {
    [super willMoveToWindow:window];
    if (window) {
        [self endEditing:YES];
    }
    
    self.btnNext.backgroundColor = LIGHT_GREEN;
}

- (void) showNext {
    [super showNext];
}

- (IBAction) privacyClicked: (id) sender {
    
    FCWebViewController* vc = [[FCWebViewController alloc] initViewWithViewModel:[[FCWebViewModel alloc] initWithUrl:PRIVACY_URL]];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    
    [self.viewController presentViewController:navController
                                      animated:TRUE
                                    completion:nil];
}

- (IBAction)nextPressed:(id)sender {
    self.loginViewModel.resultCode = FCLoginResultCodePrivacyAccepted;
}

@end
