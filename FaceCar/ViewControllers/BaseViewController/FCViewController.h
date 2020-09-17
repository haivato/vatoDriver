//
//  FCViewController.h
//  FaceCar
//
//  Created by facecar on 3/8/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCViewController : UIViewController

@property (strong, nonatomic) IBInspectable NSString* title;
@property (strong, nonatomic) IBInspectable NSString* icBtnLeft;
@property (strong, nonatomic) IBInspectable NSString* icBtnRight;
@property (assign, nonatomic) BOOL isPushedView;

- (instancetype) initViewController;
- (void) btnLeftClicked: (id) sender;

@end
