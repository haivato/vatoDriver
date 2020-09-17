//
//  FCDigitalClockTrip.h
//  FC
//
//  Created by Son Dinh on 5/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCPlace.h"

@interface FCDigitalClockTrip : FCModel

@property(nonatomic, strong) NSDate *beginTimestamp;

@property(nonatomic, assign) NSUInteger totalTime;
@property(nonatomic, assign) CGFloat totalDistance;
@property(nonatomic, assign) long long lastOnlineTime;
@property(nonatomic, assign) long long timeStarted;
@property(nonatomic, strong) FCLocation *lastLocation;
@property(nonatomic, strong) FCPlace *startLocation;
@property(nonatomic, strong) FCPlace *endLocation;
@property(nonatomic, strong) NSString* polyline;

-(instancetype)init;
@end
