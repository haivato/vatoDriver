//
//  FCTripHistory.m
//  FC
//
//  Created by Son Dinh on 6/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTripHistory.h"

@implementation FCTripHistory

- (instancetype) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self = [super initWithDictionary:dict error:err];
    NSArray* eva = [dict valueForKey:@"evaluate"];
    if ([eva count] > 0) {
        self.eval = [[eva objectAtIndex:0] integerValue];
    }
    return self;
}

- (BOOL) isTripComplete {
    return self.status == TripStatusCompleted;
}

- (BOOL) isCancelTrip {
    return (self.status == TripStatusClientCanceled ||
            self.status == TripStatusDriverCanceled ||
            self.status == TripStatusAdminCanceled);
}

- (BOOL)deliveryMode {
    return self.serviceId == VatoServiceExpress || self.serviceId == VatoServiceSupply;
}

- (NSString *)localizeServiceName {
    if (_serviceId == VatoServiceSupply && self.type != 30) {
        return @"VATO Đi chợ";
    }
    
    if (_serviceId == VatoServiceFast4) {
        return @"Taxi 4 chỗ";
    }
    
    if (_serviceId == VatoServiceFood) {
        return @"Đồ ăn & cửa hàng";
    }
    
    return [self deliveryMode] ? @"Giao hàng" : self.serviceName;
}

- (BOOL)deliveryFoodMode {
    return self.serviceId == VatoServiceFood;
}

@end
