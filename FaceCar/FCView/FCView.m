//
//  FCView.m
//  FaceCar
//
//  Created by facecar on 11/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCView.h"
#import "FCPhoneInputView.h"
#import "FCSmsCodeVerifyView.h"
#import "FCRegisterAccountView.h"

#define kDefaultShadowRadius 15
#define kDefaultOpacity 0.4f

@implementation FCView {
    void (^_showFinishedCallback)(BOOL);
}

- (id) init {
    id view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                             owner:self
                                           options:nil] firstObject];
    
    return view;
}

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
    
    if (self.isShadow) {
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(7, 7);
        self.layer.shadowRadius = self.shadowRadius > 0 ? self.shadowRadius : kDefaultShadowRadius;
        self.layer.shadowOpacity = self.shadowOpacity > 0.0f ? self.shadowOpacity : kDefaultOpacity;
    }
    
    if (self.borderColor) {
        self.layer.borderColor = [self.borderColor CGColor];
    }
    
    if (self.gradienColor) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        CGRect frame = self.bounds;
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
        gradient.frame = frame;
        gradient.colors = @[(id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)self.gradienColor.CGColor];
        [self.layer addSublayer:gradient];
    }
    
    if ([self isKindOfClass:[FCPhoneInputView class]] ||
        [self isKindOfClass:[FCSmsCodeVerifyView class]] ||
        [self isKindOfClass:[FCRegisterAccountView class]]) {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onBackgroundTouch)];
        [self addGestureRecognizer:tap];
    }
}

- (void) onBackgroundTouch {
    [self endEditing:YES];
}

- (void) show: (void (^)(BOOL finished)) block {
    _showFinishedCallback = block;
    [self show];
}

- (void) show {
    
    CGSize size = UIScreen.mainScreen.bounds.size;
    self.frame = CGRectMake(0, size.height + 250.0f, size.width, size.height);
    
    self.alpha = 0.1f;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.alpha = 1.0f;
                         self.frame = CGRectMake(0, 0, size.width, size.height);
                     } completion:^(BOOL finished) {
                         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                         if (_showFinishedCallback) {
                             _showFinishedCallback(finished);
                         }
                     }];
}

- (void) hide {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    CGSize size = UIScreen.mainScreen.bounds.size;
    self.frame = CGRectMake(0.0f, 20.0f, size.width, size.height);
    
    self.alpha = 1.0f;
    [UIView animateWithDuration:0.5f
                          delay:0.3f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.alpha = 0.01f;
                         self.frame = CGRectMake(0, size.height - 250, size.width, size.height);
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - Show | Hide next

- (void) showNext {
    
    CGSize size = UIScreen.mainScreen.bounds.size;
    self.frame = CGRectMake(size.width, 20, size.width, size.height);
    
    self.alpha = 0.1f;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.alpha = 1.0f;
                         self.frame = CGRectMake(0, 0, size.width, size.height);
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void) hideNext {
    CGSize size = UIScreen.mainScreen.bounds.size;
    self.frame = CGRectMake(0.0f, 20.0f, size.width, size.height);
    
    self.alpha = 1.0f;
    [UIView animateWithDuration:0.5f
                          delay:0.1f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.frame = CGRectMake(size.width, 20.0f, size.width, size.height);
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
