//
//  FCGooglePlaceTableViewCell.m
//  FaceCar
//
//  Created by vudang on 5/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCGooglePlaceTableViewCell.h"
#import "FCGGPlace.h"

@implementation FCGooglePlaceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void) loadData:(id)data {
    self.icon.image = [UIImage imageNamed:@"place-1"];
    self.lblName.text = ((FCPlace*)data).name;
    self.lblAddress.text = ((FCPlace*)data).address;
    
//    if ([data isKindOfClass:[GMSAutocompletePrediction class]]) {
//        self.lblName.text = ((GMSAutocompletePrediction*)data).attributedPrimaryText.string;
//        self.lblAddress.text = ((GMSAutocompletePrediction*)data).attributedSecondaryText.string;
//    }
//    else if ([data isKindOfClass:[FCGGPlace class]]) {
//        self.lblName.text = ((FCGGPlace*)data).name;
//        self.lblAddress.text = ((FCGGPlace*)data).address;
//    }
}

- (void) loadDataForHis: (FCPlaceHistory*) his {
    self.icon.image = [UIImage imageNamed:@"history"];
    self.lblName.text = his.name;
    self.lblAddress.text = his.address;
}

@end
