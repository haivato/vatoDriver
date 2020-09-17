//
//  FCLocation.h
//  FaceCar
//
//  Created by Vu Dang on 7/10/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "CLLocation+Bearing.h"

@interface FCLocation : FCModel
@property(assign, nonatomic) double lat;
@property(assign, nonatomic) double lon;

- (instancetype) initWithLat:(CLLocationDegrees) lat lon: (CLLocationDegrees) lon ;
@end
