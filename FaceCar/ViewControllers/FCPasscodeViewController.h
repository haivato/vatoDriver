//
//  FCPasscodeViewController.h
//  FC
//
//  Created by facecar on 10/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FCPasscodeViewControllerDelegate;

@interface FCPasscodeViewController : UIViewController

@property(strong, nonatomic) id<FCPasscodeViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblError;

@property (nonatomic) BOOL hasPIN;
@property (strong, nonatomic) NSString* currentPasscode;

@end

@protocol FCPasscodeViewControllerDelegate <NSObject>
- (void)passcodeViewController:(FCPasscodeViewController *)controller passcode:(NSString*)passcode;
@end
