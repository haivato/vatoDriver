//
//  FCTripDayTableViewCell.h
//  FC
//
//  Created by facecar on 6/24/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTripHistory.h"
#import <UIKit/UIKit.h>

@interface FCTripDayTableViewCell : UITableViewCell
- (void) updateData:(FCTripHistory*)trip;
@end
