//
//  UILabel+Link.m
//  FC
//
//  Created by tony on 10/4/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "UILabel+Link.h"

@implementation UILabel (Link)
- (void) underlineText: (NSString*) originString atRange:(NSRange) range {
    NSMutableAttributedString* underlineAttriString = [[NSMutableAttributedString alloc] initWithString:originString];
    [underlineAttriString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
    [underlineAttriString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:range];
    self.attributedText = underlineAttriString;
}
@end
