//
//  FCPlaceHistory.h
//  FaceCar
//
//  Created by vudang on 5/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCPlaceHistory;
@interface FCPlaceHistory : FCModel

@property (strong, nonatomic) NSString* placeId;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* address;
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) NSInteger zoneId;
@property (strong, nonatomic) FCLocation* location;
@property (assign, nonatomic) long long timestamp;


@end
