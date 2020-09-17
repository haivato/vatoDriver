//
//  FCBookClientRequest.m
//  FC
//
//  Created by facecar on 4/29/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBookInfo.h"

@implementation FCBookInfo

- (NSInteger) getBookPrice {
    NSInteger bookPrice = (self.farePrice > 0 && self.price != 0) ? self.farePrice : self.price;
    return bookPrice;
}

- (BOOL)isEqual:(id)object {
    FCBookInfo *info = [FCBookInfo castFrom:object];
    if (!info) { return NO; }
    return [self.tripId isEqual:info.tripId];
}


- (NSInteger) getType {
    if (self.tripType == BookTypeDigital) {
        return 4;
    }
    
    if (self.tripType == BookTypeOneTouch) {
        return 2;
    }
    
    return 1;
}

- (void) updateInfo:(NSArray *)tracking estimate:(FCBookEstimate *)estimate andLocation:(CLLocation *)location {
    _estimatedReceiveDistance = estimate.receiveDistance;
    _estimatedReceiveDuration = estimate.receiveDuration;
    _estimatedIntripDistance = estimate.intripDistance;
    _estimatedIntripDuration = estimate.intripDuration;
    
    for (FCBookTracking* track in tracking) {
        // Nhan chuyen
        if (track.command == BookStatusDriverAccepted) {
            _receivedAt = track.d_timestamp;
            _driverAcceptLocationLat = track.d_location.lat;
            _driverAcceptLocationLon = track.d_location.lon;
        }
        // Bat dau
        else if (track.command == BookStatusStarted) {
            _startedAt = track.d_timestamp;
            _driverStartLocationLat = track.d_location.lat;
            _driverStartLocationLon = track.d_location.lon;
            
            _actualReceiveDuration = [track.d_duration longLongValue];
            _actualReceiveDistance = [track.d_distance longLongValue];
        }
        // ket thuc
        else if (track.command >= BookStatusCompleted) {
            _finishedAt = track.d_timestamp;
            _driverFinishLocationLat = track.d_location.lat;
            _driverFinishLocationLon = track.d_location.lon;
            
            _actualIntripDistance = [track.d_distance longLongValue];
            _actualIntripDuration = [track.d_duration longLongValue];
        }
    }
    
    if (_finishedAt == 0) {
        _finishedAt = [self getCurrentTimeStamp];
    }
    
    if (_driverFinishLocationLat == 0) {
        _driverFinishLocationLon = location.coordinate.longitude;
        _driverFinishLocationLat = location.coordinate.latitude;
    }
}

- (void) updateInfoReceiveImages:(NSArray*) receiveImages {
    _receiveImages = receiveImages;
}

- (void) updateInfoDeliverImages:(NSArray*) deliverImages {
    _deliverImages = deliverImages;
}

- (BOOL)deliveryMode {
    return self.serviceId == VatoServiceExpress || self.serviceId == VatoServiceSupply;
}

- (BOOL)foodMode {
    return self.serviceId == VatoServiceFood;
}

- (NSString *)localizeServiceName {
    if (_serviceId == VatoServiceSupply && _tripType != 30) {
        return @"VATO Đi chợ";
    }
    
    if (_serviceId == 32) {
        return @"Taxi 4 chỗ";
    }
    
    if (_serviceId == VatoServiceFood) {
        return @"Đồ ăn & cửa hàng";
    }
    
    return [self deliveryMode] ? @"Giao hàng" : self.serviceName;
}

- (UIImage *)getIConService {
    if (_serviceId == VatoServiceSupply || _serviceId == VatoServiceExpress) {
       return [UIImage imageNamed:@"ic_express"];
    }
    if (_serviceId == VatoServiceFood) {
       return [UIImage imageNamed:@"ic_shopping"];
    }
    if (_serviceId == VatoServiceMoto || _serviceId == VatoServiceMotoPlus) {
       return [UIImage imageNamed:@"ic_bike"];
    }
    if (_serviceId == VatoServiceFast4 || _serviceId == VatoServiceFast7 || _serviceId == 96) {
       return [UIImage imageNamed:@"ic_taxi"];
    }
    return [UIImage imageNamed:@"ic_car"];
}

- (NSInteger)getTotalPriceOderFood {
    @try {
        NSString *jsonString = self.embeddedPayload;
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (!data) { return 0; }
        NSError *err;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)json;
            NSInteger merchantFinalPrice = [dic[@"merchantFinalPrice"] integerValue];
            return MAX(merchantFinalPrice, 0);
        }
    } @catch (NSException *exception) {
    }
    
    return 0;
}

- (NSInteger)getDiscountAmount {
    @try {
        NSString *jsonString = self.embeddedPayload;
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (!data) { return 0; }
        NSError *err;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)json;
            NSInteger discountAmount = [dic[@"discountAmount"] integerValue];
            NSInteger vatoDiscountShippingFee = [dic[@"vatoDiscountShippingFee"] integerValue];
            NSInteger discountShippingFee = [dic[@"discountShippingFee"] integerValue];
            return MAX(discountAmount + vatoDiscountShippingFee + discountShippingFee, 0);
        }
    } @catch (NSException *exception) {
    }
    
    return 0;
}

- (NSString *)supplyNote {
    if (_supplyInfo) {
        NSString *price = [self formatPrice:_supplyInfo.estimatedPrice];
        NSString *support = @"(Khách sẽ hoàn tiền mặt)";
        NSString *text = [NSString stringWithFormat:@"<a>Giá ước tính - %@</a>\n<b>%@</b>\n%@\n",price, support, _supplyInfo.productDescription ?: @""];
        return text;
    }
    
    return nil;
}

- (NSString *)noteTrip {
    NSString *text = @"";
    NSString *supply = [self supplyNote];
    if ([supply length] > 0) {
        text = supply;
    }
    text = [NSString stringWithFormat:@"%@%@", text, _note ?: @""];
    return text;
}

@end
