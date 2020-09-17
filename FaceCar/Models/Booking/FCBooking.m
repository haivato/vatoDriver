//
//  FCBooking.m
//  FC
//
//  Created by facecar on 4/29/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBooking.h"

@interface EmbeddedPayload : FCModel
@property (nonatomic, assign) NSInteger feeShip;
@property (nonatomic, assign) NSInteger discountAmount;
@property (nonatomic, assign) NSInteger discountShippingFee;
@property (nonatomic, assign) NSInteger grandTotal;
@property (nonatomic, assign) NSInteger baseGrandTotal;
@property (nonatomic, assign) NSInteger merchantFinalPrice;
@property (nonatomic, assign) NSInteger vatoDiscountShippingFee;
@property(nonatomic, copy) NSString<Optional>* vatoAppliedRuleIds;
@property(nonatomic, copy) NSString<Optional>* appliedRuleIds;
- (NSInteger) discountVato;
@end

@implementation EmbeddedPayload
- (NSInteger) discountVato {
    if (!_vatoAppliedRuleIds) {
        return 0;
    }
    
    return _discountAmount + _vatoDiscountShippingFee;
}
@end

@implementation FCBooking

- (instancetype) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self = [super initWithDictionary:dict
                               error:err];
    if (self) {
        [self setListStatus: dict];
        if (self.estimate == nil) {
            FCBookEstimate *estimate =  [FCBookEstimate new];
            estimate.intripDistance = self.info.distance;
            estimate.intripDuration = self.info.duration;
            self.estimate = estimate;
        }
    }
    
    return self;
}

- (NSInteger)discountVato {
    if (self.info.payment != PaymentMethodCash) {
        return 0;
    }
    EmbeddedPayload *extra = [self extraPayload];
    if (!extra) {
        return 0;
    }
    return [extra discountVato];
}

- (void) setListStatus: (NSDictionary*) dict {
    if ([dict objectForKey:@"command"]) {
        NSMutableArray* commands = [[NSMutableArray alloc] init];
        NSDictionary* cmdDict = [dict objectForKey:@"command"];
        for (NSDictionary* d in cmdDict.allValues) {
            FCBookCommand* stt = [[FCBookCommand alloc] initWithDictionary:d
                                                                   error:nil];
            [commands addObject:stt];
        }
        
        NSArray* array = [commands sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand* obj1,FCBookCommand* obj2) {
            return obj1.status > obj2.status;
        }];
        
        self.command = [array copy];
    }
    
    if ([dict objectForKey:@"tracking"]) {
        NSMutableArray* tracking = [[NSMutableArray alloc] init];
        NSDictionary* trackDict = [dict objectForKey:@"tracking"];
        for (NSDictionary* d in trackDict.allValues) {
            FCBookTracking* stt = [[FCBookTracking alloc] initWithDictionary:d
                                                                       error:nil];
            if (stt != nil) {
                [tracking addObject:stt];
            }
        }
        
        self.tracking = [tracking copy];
    }
}

- (void)setEstimate:(FCBookEstimate *)estimate {
    
    if (_estimate == nil) {
        _estimate = estimate;
    } else {
        NSInteger receiveDuration = estimate.receiveDuration;
        NSInteger receiveDistance = estimate.receiveDistance;
        NSInteger intripDuration = estimate.intripDuration;
        NSInteger intripDistance = estimate.intripDistance;
        BOOL condition = receiveDuration != 0 || receiveDistance != 0 || intripDuration != 0 || intripDistance != 0;
//        NSAssert(condition, @"Need check vlue");
        
        NSInteger receiveDurationOld = _estimate.receiveDuration;
        NSInteger receiveDistanceOld = _estimate.receiveDistance;
        NSInteger intripDurationOld = _estimate.intripDuration;
        NSInteger intripDistanceOld = _estimate.intripDistance;
        
        BOOL oldCondition = receiveDurationOld != 0 || receiveDistanceOld != 0 || intripDurationOld != 0 || intripDistanceOld != 0;
        if (condition || (oldCondition && !condition)) {
            _estimate = estimate;
        }
    }
}

- (BOOL)deliveryMode {
    return self.info.serviceId == VatoServiceExpress || self.info.serviceId == VatoServiceSupply;
}

- (BOOL)deliveryFoodMode {
    return self.info.serviceId == VatoServiceFood;
}

- (FCBookCommand *)last {
    if (self.command.count == 0) {
        return nil;
    }
    
    if (self.command.count == 1) {
        return self.command.firstObject;
    }
    
    NSArray* array = [self.command sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand* obj1,FCBookCommand* obj2) {
        return obj1.status > obj2.status;
    }];
    
    FCBookCommand *last = array.lastObject;
    return last;
}

- (NSDictionary*) getCommandDict {
    if (self.command.count > 0) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        for (FCBookCommand* cmd in _command) {
            NSString* key = [NSString stringWithFormat:@"%ld", (long)cmd.status];
            [dict addEntriesFromDictionary:@{key:[cmd toDictionary]}];
        }
        return @{@"command":dict};
    }
    
    return nil;
}

- (NSDictionary*) getTrackingDict {
    if (self.tracking.count > 0) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        for (FCBookTracking* track in _tracking) {
            NSString* key = [NSString stringWithFormat:@"%ld", (long)track.command];
            [dict addEntriesFromDictionary:@{key:[track toDictionary]}];
        }
        return @{@"tracking":dict};
    }
    
    return nil;
}

- (BOOL)validEstimate {
    if (!_estimate) {
        return NO;
    }
    
    return [_estimate validDistance];
}

- (EmbeddedPayload *) extraPayload {
    NSString *jsonString = self.info.embeddedPayload;
    if ([jsonString length] == 0) {
        return nil;
    }
    NSError *err;
    EmbeddedPayload *extra = [[EmbeddedPayload alloc] initWithString:jsonString error:&err];
    if (err) {
        return nil;
    }
    return extra;
}

- (NSInteger)getPriceOderFood {
    EmbeddedPayload* extraPayload = [self extraPayload];
    if (extraPayload == nil) {
        return 0;
    }
    return MAX(extraPayload.baseGrandTotal  - extraPayload.discountAmount, 0);
}
- (NSInteger)getMerchantFinalPrice {
    EmbeddedPayload* extraPayload = [self extraPayload];
     if (extraPayload == nil) {
         return 0;
     }
     return MAX(extraPayload.merchantFinalPrice, 0);
}

- (NSInteger)getTotalPriceOderFood {
    EmbeddedPayload* extraPayload = [self extraPayload];
     if (extraPayload == nil) {
         return 0;
     }
    if (self.info.payment == PaymentMethodCash) {
        return MAX(extraPayload.baseGrandTotal + extraPayload.feeShip, 0) + self.extraData.partnerTipping;
    }
    
    return MAX(extraPayload.feeShip, 0) + self.extraData.partnerTipping;
}
- (NSInteger)getTotalPriceClientPay {
    EmbeddedPayload* extraPayload = [self extraPayload];
     if (extraPayload == nil) {
         return 0;
     }
     return MAX(extraPayload.grandTotal, 0);
}

- (NSInteger)getShipFeeOderFood {
    EmbeddedPayload* extraPayload = [self extraPayload];
     if (extraPayload == nil) {
         return 0;
     }
    self.info.discountAmount = extraPayload.discountAmount;
    self.info.vatoDiscountShippingFee = extraPayload.discountShippingFee + extraPayload.vatoDiscountShippingFee;
    return MAX(extraPayload.feeShip - extraPayload.discountShippingFee - extraPayload.vatoDiscountShippingFee, 0);
}

- (NSInteger)getTotalPromotionFood {
    EmbeddedPayload* extraPayload = [self extraPayload];
      if (extraPayload == nil) {
          return 0;
      }
     return MAX(extraPayload.discountShippingFee + extraPayload.discountAmount, 0);
}

- (NSInteger)getDriverRevenue {
    EmbeddedPayload* extraPayload = [self extraPayload];
      if (extraPayload == nil) {
          return 0;
      }
    return MAX(extraPayload.feeShip, 0) + self.extraData.partnerTipping;
}

- (id)copy {
    FCBooking *bookingCopy = [[FCBooking alloc] init];
    bookingCopy.info = self.info;
    return bookingCopy;
}

@end
