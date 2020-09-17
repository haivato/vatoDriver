//
//  FCFareModifier.h
//  FaceCar
//
//  Created by facecar on 7/11/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCFareModifier : FCModel
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) NSInteger additionAmount;
@property (nonatomic, assign) NSInteger additionMax;
@property (nonatomic, assign) NSInteger additionMin;
@property (nonatomic, assign) double additionRatio;
@property (nonatomic, assign) NSInteger clientDelta;
@property (nonatomic, assign) NSInteger clientFixed;
@property (nonatomic, assign) NSInteger clientMax;
@property (nonatomic, assign) NSInteger clientMin;
@property (nonatomic, assign) double clientRatio;
@property (nonatomic, assign) NSInteger driverActiveAmount;
@property (nonatomic, assign) NSInteger driverMax;
@property (nonatomic, assign) NSInteger driverMin;
@property (nonatomic, assign) double driverRatio;

@end
