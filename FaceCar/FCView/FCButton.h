//
//  FCButton.h
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Border.h"

@interface FCButton : UIButton
@property (strong, nonatomic) IBInspectable UIColor* disableColor;
@property (strong, nonatomic) IBInspectable UIColor* enableColor;
@property (assign, nonatomic) IBInspectable BOOL isCircle;
@property (assign, nonatomic) IBInspectable BOOL isShadow;
@property (assign, nonatomic) IBInspectable NSInteger cornerRadius;
@property (strong, nonatomic) IBInspectable UIColor* borderColor;
@property (assign, nonatomic) IBInspectable NSInteger shadowRadius;
@property (assign, nonatomic) IBInspectable CGFloat shadowOpacity;
@end
