//
//  UIAlertController+Label.m
//  FC
//
//  Created by tony on 10/2/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "UIAlertController+Label.h"

@implementation UIAlertController (Label)
@dynamic titleLabel;
@dynamic messageLabel;

- (NSArray *)viewArray:(UIView *)root {
    NSLog(@"%@", root.subviews);
    static NSArray *_subviews = nil;
    _subviews = nil;
    for (UIView *v in root.subviews) {
        if (_subviews) {
            break;
        }
        if ([v isKindOfClass:[UILabel class]]) {
            _subviews = root.subviews;
            return _subviews;
        }
        [self viewArray:v];
    }
    return _subviews;
}

- (UILabel *)titleLabel {
    return [self viewArray:self.view][0];
}

- (UILabel *)messageLabel {
    return [self viewArray:self.view][1];
}

@end
