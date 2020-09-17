//
//  FCCreateCarViewController.h
//  FC
//
//  Created by facecar on 5/9/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Border.h"
#import "FCHomeViewModel.h"
//#import "swift"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

@interface FCCreateCarViewController : UITableViewController

@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (strong, nonatomic) FCUCar* car;
@property (nonatomic) RSListServiceObjcWrapper *rsListServicePackageObjcWrapper;

- (instancetype) initView;

@end
