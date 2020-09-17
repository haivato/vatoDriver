//
//  FCPlace.m
//  FaceCar
//
//  Created by Vu Dang on 6/23/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCPlace.h"

@implementation FCPlace
- (CLLocation*) getCLLocation
{
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.location.lat longitude:self.location.lon];
    return loc;
}
@end
