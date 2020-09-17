//
//  FCPointView.m
//  FC
//
//  Created by khoi tran on 4/8/20.
//  Copyright © 2020 Vato. All rights reserved.
//

#import "FCPointView.h"

@implementation FCPointView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)setupDisplay:(NSString *)address origin:(BOOL) isOrigin {
    
    if (isOrigin) {
        [self.tripTypeImageView setImage: [UIImage imageNamed:@"marker-start"]];
    } else {
        [self.tripTypeImageView setImage: [UIImage imageNamed:@"marker-end"]];
    }
    
    [self.addressLabel setText:address];
}


@end
