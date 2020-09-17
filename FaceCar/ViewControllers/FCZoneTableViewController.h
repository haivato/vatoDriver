//
//  FCZoneTableViewController.h
//  FC
//
//  Created by facecar on 5/6/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCZoneViewModel.h"

@interface FCZoneTableViewController : UITableViewController

- (instancetype) initView;

@property (strong, nonatomic) FCZoneViewModel* viewModel;
@property (strong, nonatomic) FCZone* zoneSelected;

@end
