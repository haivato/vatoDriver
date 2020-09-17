//
//  GoogleAutoCompleteViewController.h
//  FaceCar
//
//  Created by facecar on 5/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleViewModel.h"
@import GooglePlaces;

@interface GoogleAutoCompleteViewController : UIViewController

@property (strong, nonatomic) GoogleViewModel* googleViewModel;
@property (strong, nonatomic) FCGGMapView* mapview;
- (instancetype) initViewController;

@end
