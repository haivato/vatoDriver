//
//  FCBookExtra.m
//  FaceCar
//
//  Created by facecar on 6/8/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBookExtra.h"

@implementation FCBookExtra
- (BOOL)isEqual:(id)object {
    FCBookExtra *obj2 = [FCBookExtra castFrom:object];
    if (!obj2) { return NO; }
    return (_driverCash == obj2.driverCash)
    && (_driverCoin == obj2.driverCoin)
    && ([_polylineIntrip isEqual:obj2.polylineIntrip])
    && ([_polylineReceive isEqual:obj2.polylineReceive])
    && (_satisfied == obj2.satisfied);
}
@end
