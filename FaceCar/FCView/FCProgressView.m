//
//  FCProgressView.m
//  FaceCar
//
//  Created by facecar on 11/19/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCProgressView.h"
#define TIME_ANIM 5.0f

@implementation FCProgressView {
    NSTimer *_loadingTimer;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self setProgress:0.0f animated:NO];
    if (self.showOnStart) {
        [self show];
    }
    else {
        self.hidden = YES;
    }
    
    self.progressTintColor = [UIColor orangeColor];
    self.trackTintColor = [UIColor clearColor];
}

- (void) setProgressType: (FCProgressType) type {
    if (type == FCProgressTypeAllowInteraction) {
    }
    else {
    }
}

- (void) show {
    self.hidden = NO;
    [self setProgress:0.0f animated:NO];
    _loadingTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_ANIM
                                                     target:self
                                                   selector:@selector(start)
                                                   userInfo:nil
                                                    repeats:TRUE];
    [_loadingTimer fire];
}

- (void) dismiss {
    [_loadingTimer invalidate];
    [self setProgress:0.0 animated:NO];
    self.hidden = TRUE;
}

- (void) start {
    [self setProgress:0.0f animated:NO];
    [UIView animateWithDuration:TIME_ANIM/2.0f
                     animations:^{
                         [self setProgress:1.0f animated:YES];
                     }
                     completion:^(BOOL finished) {

                     }];

    // repeat
    [NSTimer scheduledTimerWithTimeInterval:TIME_ANIM/2.0f
                                     target:self
                                   selector:@selector(repeat)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) repeat {
    [self setProgress:1.0f animated:NO];
    [UIView animateWithDuration:TIME_ANIM/2.0f
                     animations:^{
                         [self setProgress:0.0f animated:YES];
                     }
                     completion:^(BOOL finished) {

                     }];
}

@end
