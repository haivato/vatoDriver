//
//  FCSupperViewController.h
//  FC
//
//  Created by facecar on 5/8/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCSupperViewController : UIViewController

- (instancetype) initView;
- (UINavigationController*) loadWithNavi;

- (void) setupBackNav;
- (void) setupCloseNav;

- (void) backPressed: (id) sender;
- (void) closePressed: (id) sender;

@end
