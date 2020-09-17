//
//  FCServiceCollectionViewCell.m
//  FC
//
//  Created by facecar on 7/28/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCServiceCollectionViewCell.h"

@implementation FCServiceCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)onChooseChanged:(id) sender {
    [self.delegate serviceCell:self
                     onChoosed:self.swChoose.on
                       service:self.service];
}


@end
