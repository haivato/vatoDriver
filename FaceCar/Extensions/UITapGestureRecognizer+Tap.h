//
//  UITapGestureRecognizer+Tap.h
//  FC
//
//  Created by tony on 10/4/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITapGestureRecognizer (Tap)
- (BOOL) didTapAttributedTextInLabel:(UILabel*) label inRange:(NSRange) targetRange;
@end
