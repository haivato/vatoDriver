//
//  FCImageView.m
//  FaceCar
//
//  Created by facecar on 12/10/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCImageView.h"
#import "UIView+Border.h"

@implementation FCImageView


- (void) awakeFromNib {
    [super awakeFromNib];
    
    if (self.isCircle) {
        [self circleView:[UIColor clearColor]];
    }
    else {
        [self borderViewWithColor:[UIColor clearColor] andRadius:self.cornerRadius];
    }
}

- (void) setImageWithUrl: (NSString*) url {
    @try {
        [self setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                    placeholderImage:[UIImage imageNamed:@"app"]
                             success:nil
                             failure:nil];
    }
    @catch (NSException* e) {}
}

- (void) setImageWithUrl: (NSString*) url
                  holder: (UIImage*) holder {
    @try {
        [self setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                    placeholderImage:holder
                             success:nil
                             failure:nil];
    }
    @catch (NSException* e) {}
}

@end
