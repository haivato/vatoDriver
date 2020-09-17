//
//  FCGooglePlaceTableViewCell.h
//  FaceCar
//
//  Created by vudang on 5/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCPlaceHistory.h"
@import GooglePlaces;

@interface FCGooglePlaceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;

- (void) loadData: (id) data;
- (void) loadDataForHis: (FCPlaceHistory*) his;

@end
