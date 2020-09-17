//
//  FCToast.m
//  FaceCar
//
//  Created by facecar on 11/16/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCToast.h"
#import "UIView+Border.h"

@implementation FCToast {

}

- (instancetype) initView {
    id view =   [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    
    return view;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(15, 30, [UIScreen mainScreen].bounds.size.width - 30, self.bounds.size.height);
    
    [self borderViewWithColor:[UIColor clearColor] andRadius:self.bounds.size.height/2];
}

- (void) show {
    [NSTimer scheduledTimerWithTimeInterval:3
                                     target:self
                                   selector:@selector(onDismiss)
                                   userInfo:nil
                                    repeats:NO];
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    [UIView animateWithDuration:1
                     animations:^{
                         self.alpha = 1;
                         self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void) onDismiss {
    self.alpha = 1;
    self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    [UIView animateWithDuration:1
                     animations:^{
                         self.alpha = 0.1;
                         self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                     }
                     completion:^(BOOL finished) {
                        [self removeFromSuperview];
                     }];
}

@end
