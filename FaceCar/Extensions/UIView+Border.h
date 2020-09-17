//
//  NSString+MD5.h
//  FC
//
//  Created by Son Dinh on 4/29/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIView (Border)

- (void) borderViewWithColor: (UIColor*) color andRadius: (NSInteger) radius;
- (void) borderViewWithColor:(UIColor *)color andBorderWidth:(NSInteger)borderWidth andRadius:(NSInteger)radius;

- (void) circleView;
- (void) circleView: (UIColor*) boderColor;
- (void) shadowView;
@end
