//
//  LocationUtil.h
//  FaceCar
//
//  Created by facecar on 7/11/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationUtil : NSObject
+ (BOOL) inDistance: (double) distance
            fromLat: (double) flat
            fromLon: (double) flon
              toLat: (double) tlat
              toLon: (double) tlon;
@end
