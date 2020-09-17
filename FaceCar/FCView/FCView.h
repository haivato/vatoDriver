//
//  FCView.h
//  FaceCar
//
//  Created by facecar on 11/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCButtonNext.h"
#import "FCProgressView.h"

@interface FCView : UIView

@property (strong, nonatomic) id viewController;

@property (assign, nonatomic) IBInspectable BOOL isCircle;
@property (assign, nonatomic) IBInspectable BOOL isShadow;

@property (assign, nonatomic) IBInspectable NSInteger cornerRadius;
@property (assign, nonatomic) IBInspectable NSInteger shadowRadius;
@property (assign, nonatomic) IBInspectable CGFloat shadowOpacity;

@property (strong, nonatomic) IBInspectable UIColor* gradienColor;
@property (strong, nonatomic) IBInspectable UIColor* borderColor;

@property (assign, nonatomic) BOOL isFinishedView;

- (instancetype) intView;

- (void) show: (void (^)(BOOL finished)) block;
- (void) show;
- (void) hide;

- (void) showNext;
- (void) hideNext;
@end
