//
//  VehicleServiceUtil.h
//  FaceCar
//
//  Created by facecar on 7/11/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VehicleServiceUtil : NSObject
+ (NSArray*) splitService: (NSInteger) service;
+ (NSString*) getServiceName: (NSInteger) service;
@end
