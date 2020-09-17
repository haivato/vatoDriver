//
//  DateTimeUtils.h
//  FaceCar
//
//  Created by facecar on 7/11/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeUtils : NSObject

+ (long long) atStartOfDayTimestamp: (long long) timestamp;

+ (long long) atEndOfDayTimestamp: (long long) timestamp;

+ (long long) atStartOfDate: (NSDate*) date;

+ (long long) atEndOfDate: (NSDate*) date;

+ (float) getHour: (long long) timestamp;

+ (NSInteger) getMonth: (long long) timestamp;

@end
