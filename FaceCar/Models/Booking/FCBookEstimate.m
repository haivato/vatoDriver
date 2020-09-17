//
//  FCBookTrackingEstimate.m
//  FC
//
//  Created by facecar on 11/16/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCBookEstimate.h"

@implementation FCBookEstimate
- (BOOL)isEqual:(id)object {
    FCBookEstimate *obj2 = [FCBookEstimate castFrom:object];
    if (!obj2) { return NO; }
    return (_receiveDistance == obj2.receiveDistance)
    && (_receiveDuration == obj2.receiveDuration)
    && (_intripDuration == obj2.intripDuration)
    && (_intripDistance == obj2.intripDistance);
}

- (BOOL)validDistance {
    return _receiveDistance > 0;
}
@end
