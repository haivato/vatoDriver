//
//  HomeViewController.h
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NSObject+Helper.h"
#import "FCHomeViewModel.h"
@import GoogleMaps;

@interface HomeViewController : UIViewController

@property (strong, nonatomic) FCHomeViewModel* viewModel;

@end
