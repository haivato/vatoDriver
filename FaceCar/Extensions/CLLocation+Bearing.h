//
//  CLLocation+Bearing.h
//  FaceCar
//
//  Created by Vu Dang on 7/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface CLLocation (Bearing)

- (double) bearingToLocation:(CLLocation *) destinationLocation;
@end
