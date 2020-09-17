//
//  FCButton.m
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCButton.h"

#define kDefaultShadowRadius 15
#define kDefaultOpacity 0.4f

@implementation FCButton

- (void) awakeFromNib {
    [super awakeFromNib];
    
    if (self.isCircle) {
        [self circleView:[UIColor clearColor]];
    }
    else {
        [self borderViewWithColor:[UIColor clearColor] andRadius:self.cornerRadius];
    }
    
    if (self.borderColor) {
        self.layer.borderColor = self.borderColor.CGColor;
    }
    
    if (self.isShadow) {
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(7, 7);
        
        self.layer.shadowRadius = self.shadowRadius > 0 ? self.shadowRadius : kDefaultShadowRadius;
        self.layer.shadowOpacity = self.shadowOpacity > 0.0f ? self.shadowOpacity : kDefaultOpacity;
    }
    
    self.backgroundColor = NewOrangeColor; //LIGHT_GREEN;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end
