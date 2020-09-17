//
//  FCLabel.m
//  FaceCar
//
//  Created by facecar on 12/9/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCLabel.h"

@implementation FCLabel

- (instancetype) intView {
    id view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                             owner:self
                                           options:nil] firstObject];
    return view;
}

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
        self.layer.borderWidth = 0.5f;
    }
    
    if (self.isShadow) {
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(7, 7);
        self.layer.shadowRadius = 15;
        self.layer.shadowOpacity = 0.4;
    }
}

@end
