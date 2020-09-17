//
//  FCTripDetailViewController.h
//  FC
//
//  Created by facecar on 6/24/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCTripHistory.h"

@interface FCTripDetailViewController : UITableViewController
- (instancetype) initView:(FCTripHistory*)tripHistory;
@end
