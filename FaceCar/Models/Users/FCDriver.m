//
//  FCDriver.m
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCDriver.h"
#import "FCDriverRatio.h"
#import "FCLocation.h"
#import "FCDevice.h"
#import "FCUser.h"
#import "FCUCar.h"
#import "FCBlock.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
@implementation FCDriver
@synthesize active = _active;
@synthesize enableTransferCash = _enableTransferCash;

- (id) init {
    self = [super init];
    
    if (self) {
        self.user = [[FCUser alloc] init];
    }
    
    return self;
}

- (void) setActive:(NSNumber *)active {
    _active = @([active boolValue]);
}

- (void) setEnableTransferCash:(NSNumber *)enableTransferCash {
    _enableTransferCash = @([enableTransferCash boolValue]);
}

- (BOOL)isEqual:(id)object {
    FCDriver *new = [FCDriver castFrom:object];
    if (!new) {
        return NO;
    }
    
    return ([self.user isEqual:new.user]
            && [self.vehicle isEqual:new.vehicle]
            && [self.deviceInfo isEqual:new.deviceInfo]
            && [self.lock isEqual:new.lock]);
}

- (uint64_t)userId {
    return self.user.id;
}

- (NSString *)firebaseId {
    return self.user.firebaseId;
}

- (NSString *)serviceName {
    return self.vehicle.serviceName;
}

- (NSString *)marketName {
    return self.vehicle.marketName;
}

- (NSInteger)serviceId {
    return self.vehicle.service;
}

- (BOOL)actived {
    return [self.active boolValue];
}

- (NSString *)plate {
    return self.vehicle.plate;
}

- (uint64_t)taxiBrandId {
    return self.vehicle.taxiBrand;
}

- (NSArray *)services {
    return self.vehicle.services;
}

@end
