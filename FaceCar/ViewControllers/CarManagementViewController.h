//
//  CarManagementViewController.h
//  FC
//
//  Created by Son Dinh on 5/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCSupperViewController.h"
#import "FCHomeViewModel.h"
#import "FCUCar.h"

@interface CarManagementViewController : FCSupperViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FCHomeViewModel* homeViewModel;

- (instancetype) initViewWithHomeViewModel: (FCHomeViewModel*) homeViewModel;

@end
