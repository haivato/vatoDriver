//
//  DigitalClockViewController.h
//  FC
//
//  Created by Son Dinh on 5/23/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBSliderView.h"
#import "FCDigitalClockTrip.h"
#import "ReceiptView.h"
#import "FCBooking.h"
#import "TimeUtils.h"

@interface DigitalClockViewController : UIViewController<MBSliderViewDelegate, ReceipViewDelegate>
@property(nonatomic, strong) FCDigitalClockTrip *clockTrip;
@property(nonatomic, strong) FCBooking *booking;
@end
