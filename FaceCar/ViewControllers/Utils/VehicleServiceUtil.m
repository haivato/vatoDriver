//
//  VehicleServiceUtil.m
//  FaceCar
//
//  Created by facecar on 7/11/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "VehicleServiceUtil.h"

@implementation VehicleServiceUtil

+ (NSArray*) splitService: (NSInteger) service {
    NSArray* arr = @[@1,@2,@4,@8,@16, @32, @64];
    return [arr filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id s, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ([s integerValue] & service) == [s integerValue];
    }]];
}

+ (NSString*) getServiceName:(NSInteger)service {
    NSString* name;
    switch (service) {
        case VatoServiceCar:
            name = @"VATO Car";
            break;
        case VatoServiceCarPlus:
            name = @"VATO Car+";
            break;
        case VatoServiceCar7:
            name = @"VATO 7 chỗ";
            break;
        case VatoServiceMoto:
            name = @"VATO Bike";
            break;
        case VatoServiceMotoPlus:
            name = @"VATO Bike+";
            break;
        case VatoServiceFast4:
            name = @"VATO Fast 4 chỗ";
            break;
        case VatoServiceFast7:
            name = @"VATO Fast 7 chỗ";
            break;
        default:
            break;
    }
    
    return name;
}
@end
