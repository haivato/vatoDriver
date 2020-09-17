//
//  FCMReceipt.h
//  FaceCar
//
//  Created by Vu Dang on 6/11/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCFareSetting : FCModel
@property(assign, nonatomic) NSInteger firstKm;
@property(assign, nonatomic) NSInteger min;
@property(assign, nonatomic) NSInteger perKm;
@property(assign, nonatomic) NSInteger perMin;
@property(assign, nonatomic) NSInteger priority;
@property(assign, nonatomic) NSInteger service;
@property(assign, nonatomic) NSInteger tripType;
@property(assign, nonatomic) NSInteger zoneId;

@property(assign, nonatomic) NSInteger id;
@property(assign, nonatomic) BOOL active;
@property(assign, nonatomic) NSInteger percent;
@property(assign, nonatomic) NSInteger perHour;
@property(assign, nonatomic) Boolean expired;
@property(assign, nonatomic) NSInteger taxiBrand;
@property(assign, nonatomic) NSInteger wayPointFee;


@end
