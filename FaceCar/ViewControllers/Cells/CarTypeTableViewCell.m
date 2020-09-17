//
//  CarTypeTableViewCell.m
//  FaceCar
//
//  Created by Vu Dang on 6/11/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "CarTypeTableViewCell.h"

@implementation CarTypeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void) loadData: (FCMCarType*) carType {
    self.name.text = carType.name;
}

@end
