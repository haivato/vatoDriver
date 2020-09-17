//
//  MenusTableViewController.h
//  FaceCar
//
//  Created by Vu Dang on 6/1/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

@interface MenusTableViewController : UITableViewController
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (nonatomic, copy) void (^didSelecFavMode )(ActiveFavoriteModeModel*);

- (void) bindingData;

@end
