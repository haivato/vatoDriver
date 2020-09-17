//
//  FCBlockAccountView.m
//  FC
//
//  Created by facecar on 8/3/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCBlockAccountView.h"
#import "UIView+Border.h"

@implementation FCBlockAccountView

+ (UIView*) initView {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"FCBlockAccountView" owner:self options:nil] objectAtIndex:0];
    view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    return view;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self.backgroun borderViewWithColor:[UIColor clearColor] andRadius:5];
}

@end
