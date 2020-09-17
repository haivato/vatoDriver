//
//  FCPartnerTableViewCell.m
//  FaceCar
//
//  Created by facecar on 12/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPartnerTableViewCell.h"

@implementation FCPartnerTableViewCell

- (id) init {
    id view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
