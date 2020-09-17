//
//  FCTripHistory.h
//  FC
//
//  Created by Son Dinh on 6/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCInvoice.h"

@interface FCTripHistory : FCModel
@property (nonatomic, assign) NSInteger createdBy;
@property (nonatomic, assign) NSInteger updatedBy;
@property (nonatomic, assign) NSInteger createdAt;
@property (nonatomic, assign) NSInteger updatedAt;
@property (nonatomic, assign) NSInteger additionPrice;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString* clientFirebaseId;
@property (nonatomic, assign) NSInteger clientId;
@property (nonatomic, strong) NSString* contactPhone;
@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, strong) NSString *driverFirebaseId;
@property (nonatomic, assign) NSInteger driverId;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, copy)   NSString *endAddress;
@property (nonatomic, assign) double endLat;
@property (nonatomic, assign) double endLon;
@property (nonatomic, copy)   NSString *endName;
@property (nonatomic, assign) NSInteger price;
@property (nonatomic, assign) NSInteger promotionValue;
@property (nonatomic, assign) NSInteger serviceId;
@property (nonatomic, copy)   NSString *serviceName;
@property (nonatomic, copy)   NSString *startAddress;
@property (nonatomic, assign) double startLat;
@property (nonatomic, assign) double startLon;
@property (nonatomic, copy)   NSString *startName;
@property (nonatomic, assign) NSInteger timestamp;
@property (nonatomic, assign) NSInteger zoneId;
@property (nonatomic, strong)  NSString* tripCode;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSInteger statusDetail;
@property (nonatomic, strong) NSString* id;
@property (nonatomic, strong) NSString* note;

// promotion
@property(assign, nonatomic) NSInteger modifierId;
@property(assign, nonatomic) NSInteger farePrice;
@property(assign, nonatomic) NSInteger fareClientSupport;
@property(assign, nonatomic) NSInteger fareDriverSupport;

@property (nonatomic, assign) NSInteger payment;
@property (nonatomic, assign) NSInteger promotionModifierId;

@property (nonatomic, assign) BOOL confirmEvaluate;
@property (nonatomic, assign) NSInteger eval;

- (BOOL) isTripComplete;
- (BOOL) isCancelTrip;
- (NSString *)localizeServiceName;
- (BOOL)deliveryFoodMode;
@end
