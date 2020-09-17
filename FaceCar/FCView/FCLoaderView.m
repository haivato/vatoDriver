//
//  FCLoaderView.m
//  FaceCar
//
//  Created by facecar on 11/28/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCLoaderView.h"
#import "UIView+Border.h"

@implementation FCLoaderView

- (id) init {
    self = [super init];
    if (self) {
        [self configView];
    }
    return self;
}

- (void) configView {
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    CGFloat radius = sqrt(w*w/4 + h*h/4);
    
    CGRect frame = CGRectMake(w/2 - radius, h/2 - radius, 2*radius, 2*radius);
    self.frame = frame;
    [self circleView:[UIColor clearColor]];
    
    // icon
    CGFloat imgSize = 65;
    UIImageView* logoView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - imgSize)/2, (frame.size.height - imgSize)/2, imgSize, imgSize)];
    logoView.image = [UIImage imageNamed:@"icon_logo"];
    [self addSubview:logoView];
    self.backgroundColor = [UIColor whiteColor];
}

- (void) start: (void (^) (void)) completed {
    self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         completed();
                     }];
}

@end
