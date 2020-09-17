//
//  FCFarePredicate.h
//  FaceCar
//
//  Created by facecar on 7/11/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCFarePredicate : FCModel
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) NSInteger endDate;
@property (nonatomic, assign) NSInteger endDistance;
@property (nonatomic, assign) double endLat;
@property (nonatomic, assign) double endLon;
@property (nonatomic, assign) double endTime;
//@property (nonatomic, assign) double expired;
@property (nonatomic, assign) NSInteger fareMax;
@property (nonatomic, assign) NSInteger fareMin;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger manifestId;
@property (nonatomic, assign) NSInteger modifierId;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) NSInteger service;
@property (nonatomic, assign) NSInteger startDate;
@property (nonatomic, assign) NSInteger startDistance;
@property (nonatomic, assign) double startLat;
@property (nonatomic, assign) double startLon;
@property (nonatomic, assign) double startTime;
@property (nonatomic, assign) NSInteger tripType;

@property (nonatomic, strong) NSString<Optional>* banner;
@property (nonatomic, strong) NSString<Optional>* title;
//@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) NSString<Optional>* url;
@end
