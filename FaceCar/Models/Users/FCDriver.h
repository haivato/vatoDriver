//
//  FCDriver.h
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCModel.h"

@class FCLocation;
@class FCDevice;
@class FCUser;
@class FCUCar;
@class FCBlock;

@protocol VatoDriverProtocol;
@interface FCDriver : FCModel<VatoDriverProtocol>

@property(strong, nonatomic) FCUser* user;
@property(strong, nonatomic) NSString* code;
@property(strong, nonatomic) FCUCar* vehicle;
@property(strong, nonatomic) NSNumber* active;
@property(strong, nonatomic) NSNumber* enableTransferCash;
@property(strong, nonatomic) NSString* deviceToken;
@property(strong, nonatomic) NSString* currentVersion;
@property(strong, nonatomic) NSString* group;
@property(strong, nonatomic) FCDevice* deviceInfo;
@property(assign, nonatomic) long long created;
@property(strong, nonatomic) NSString* topic;
@property(assign, nonatomic) NSInteger zoneId;
@property(strong, nonatomic) NSNumber* autoAccept;
@property(strong, nonatomic) FCBlock* lock;

@end
