//
//  BookViewController.h
//  FC
//
//  Created by Son Dinh on 3/28/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *labelAppVersion;

@property (weak, nonatomic) UIAlertController* alertView;
- (void) stopTimer;

- (void) hideAnyPopup: (void (^) (void)) completed;
+ (BookViewController *) createVC;
@end
