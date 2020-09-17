//
//  LocationUtil.m
//  FaceCar
//
//  Created by facecar on 7/11/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "LocationUtil.h"

@implementation LocationUtil
+ (BOOL) inDistance: (double) distance
            fromLat: (double) flat
            fromLon: (double) flon
              toLat: (double) tlat
              toLon: (double) tlon {
    
    if (flat == 0 || flon == 0 || tlat == 0 || tlon == 0) {
        return TRUE;
    }
    
    CLLocation* from = [[CLLocation alloc] initWithLatitude:flat
                                                  longitude:flon];
    CLLocation* to = [[CLLocation alloc] initWithLatitude:tlat
                                                longitude:tlon];
    double dis = [from distanceFromLocation:to];
    return dis <= distance;
}

@end
