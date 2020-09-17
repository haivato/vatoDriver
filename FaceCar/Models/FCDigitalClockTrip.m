//
//  FCDigitalClockTrip.m
//  FC
//
//  Created by Son Dinh on 5/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCDigitalClockTrip.h"

@implementation FCDigitalClockTrip
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.beginTimestamp = [NSDate date];
        self.totalTime = 0.0f;
        self.totalDistance = 0.0f;
        self.lastOnlineTime = 0.0;
        self.lastLocation = nil;
        self.startLocation = nil;
        self.endLocation = nil;
    }
    
    return self;
}
@end
