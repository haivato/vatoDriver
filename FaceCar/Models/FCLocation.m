//
//  FCLocation.m
//  FaceCar
//
//  Created by Vu Dang on 7/10/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCLocation.h"

@interface FCLocation()
{
    CLLocation *_googleLocation;
}

@end
@implementation FCLocation

+(BOOL)propertyIsIgnored:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"googleLocation"])
    {
        return YES;
    }
    
    return NO;
}

- (instancetype) initWithLat:(CLLocationDegrees) lat lon: (CLLocationDegrees) lon {
    self = [super init];
    self.lat = lat;
    self.lon = lon;
    return self;
}

- (CLLocation*)googleLocation
{
    if (_googleLocation == nil)
    {
        _googleLocation = [[CLLocation alloc] initWithLatitude:self.lat longitude:self.lon];
    }
    return _googleLocation;
}

- (void)setGoogleLocation:(CLLocation *)googleLocation
{
    _googleLocation = googleLocation;
}
@end
