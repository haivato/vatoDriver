//
//  FCLabel.h
//  FaceCar
//
//  Created by facecar on 12/9/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCLabel : UILabel
@property (assign, nonatomic) IBInspectable BOOL isCircle;
@property (assign, nonatomic) IBInspectable BOOL isShadow;
@property (assign, nonatomic) IBInspectable NSInteger cornerRadius;
@property (strong, nonatomic) IBInspectable UIColor* borderColor;
@end
