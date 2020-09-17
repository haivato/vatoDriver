//
//  FCButton.m
//  FaceCar
//
//  Created by facecar on 11/19/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCButton.h"
#import "UIView+Border.h"

#define kEnableColorDefault [UIColor blackColor]
#define kDisableColorDefault [UIColor lightGrayColor]

@implementation FCButtonNext {
    CGFloat _scaleFrom, _scaleTo;
    BOOL _hidden;
    CAShapeLayer *_circleLayer;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    if (self.isCircle) {
        [self circleView:[UIColor clearColor]];
    }
    
    if (self.isEnable) {
        [self setEnabled:_isEnable];
    }
    
    self.backgroundColor = self.disableColor;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (self.isLoadingWhenPress) {
        [self loadingProgress];
    }
}

- (void) loadingProgress {
    _circleLayer = [CAShapeLayer layer];
    CGFloat size = self.bounds.size.width/2;
    _circleLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(size, size)
                                                       radius:(size - 3)
                                                   startAngle:-M_PI_2
                                                     endAngle:2 * M_PI - M_PI_2
                                                    clockwise:YES].CGPath;
    
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    _circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    _circleLayer.lineWidth = 2.0f;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 3.0f;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = YES;
    animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_circleLayer addAnimation:animation forKey:@"drawCircleAnimation"];
    [self.layer addSublayer:_circleLayer];
}

- (void) dismissProcess {
    if (_circleLayer) {
        [_circleLayer removeAllAnimations];
        [_circleLayer removeFromSuperlayer];
    }
}

- (void) setHidden:(BOOL)hidden {
    [super setHidden:!hidden];
    
    if (hidden) {
        _scaleFrom = 1.0f;
        _scaleTo = 0.1f;
    }
    else {
        _scaleFrom = 0.1f;
        _scaleTo = 1.0f;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.5f
                                     target:self
                                   selector:@selector(startHidden)
                                   userInfo:nil
                                    repeats:NO];
    
    
}

- (void) startHidden {
    [super setHidden:_hidden];
    
    self.transform = CGAffineTransformMakeScale(_scaleFrom, _scaleFrom);
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(_scaleTo, _scaleTo);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void) setEnabled:(BOOL) enabled {
    [super setEnabled:enabled];
    
    
//    if (!self.enableColor) {
//        self.enableColor = kEnableColorDefault;
//    }
    self.enableColor = NewOrangeColor;
    
    if (!self.disableColor) {
        self.disableColor = kDisableColorDefault;
    }
    
    if (enabled) {
        self.backgroundColor = self.enableColor;
        [self dismissProcess];
    }
    else {
        self.backgroundColor = self.disableColor;
    }
}

@end
