//
//  FCPlace.h
//  FaceCar
//
//  Created by Vu Dang on 6/23/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCLocation.h"

@interface FCPlace : FCModel
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSString* address;
@property(strong, nonatomic) NSString* placeId;
@property(strong, nonatomic) FCLocation* location;
@property(assign, nonatomic) NSInteger zoneId;

- (CLLocation*) getCLLocation;
@end
