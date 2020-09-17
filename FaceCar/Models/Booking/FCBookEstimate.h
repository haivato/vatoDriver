//
//  FCBookTrackingEstimate.h
//  FC
//
//  Created by facecar on 11/16/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCBookEstimate : FCModel
@property(assign, nonatomic) NSInteger receiveDuration;
@property(assign, nonatomic) NSInteger receiveDistance;
@property(assign, nonatomic) NSInteger intripDuration;
@property(assign, nonatomic) NSInteger intripDistance;

- (BOOL)validDistance;
@end
