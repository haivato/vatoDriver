//
//  FCBookTracking.h
//  FC
//
//  Created by facecar on 11/15/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCBookTracking;
@interface FCBookTracking : FCModel

@property (assign, nonatomic) NSInteger command;
@property (strong, nonatomic) NSString* polyline;

// for driver
@property (strong, nonatomic) FCLocation* d_location;
@property (assign, nonatomic) long long d_timestamp;
@property (strong, nonatomic) NSString* d_localTime;
@property (strong, nonatomic) NSNumber* d_duration;
@property (strong, nonatomic) NSNumber* d_distance;

// for client
@property (strong, nonatomic) FCLocation* c_location;
@property (strong, nonatomic) NSNumber* c_timestamp;
@property (strong, nonatomic) NSString* c_localTime;
@property (strong, nonatomic) NSNumber* c_duration;
@property (strong, nonatomic) NSNumber* c_distance;
@end
