//
//  CarManageTableViewCell.h
//  FC
//
//  Created by Son Dinh on 5/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"
#import "FCUCar.h"

@interface CarManageTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *carImage;
@property (strong, nonatomic) IBOutlet UILabel *labelCarName;
@property (strong, nonatomic) IBOutlet UILabel *labelLicense;
@property (weak, nonatomic) IBOutlet UILabel *lblCarStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblCarService;

@property (nonatomic, copy) void (^edit)(FCUCar* car);
@property (nonatomic, copy) void (^del)(FCUCar* car);
@property (nonatomic, copy) void (^choose)(FCUCar* car);

@property (strong, nonatomic) FCHomeViewModel* homeViewModel;

- (void)loadData:(FCUCar*)car;
@end
