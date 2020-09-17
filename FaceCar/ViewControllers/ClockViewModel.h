//
//  ClockViewModel.h
//  FC
//
//  Created by facecar on 8/3/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCDigitalClockTrip.h"

@interface ClockViewModel : NSObject

@property (strong, nonatomic) FCDigitalClockTrip* clock;
- (instancetype) initClockForBook: (FCBooking*) book;
- (void) startClock;
- (void) stopClock;
+ (FCDigitalClockTrip*)getLastClock: (NSString*) tripid;
@end
