//
//  DateTimeUtils.m
//  FaceCar
//
//  Created by facecar on 7/11/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "DateTimeUtils.h"

@implementation DateTimeUtils


+ (long long) atStartOfDayTimestamp: (long long) timestamp {
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [self.class atStartOfDate:date];
}

+ (long long) atEndOfDayTimestamp: (long long) timestamp {
    long long time = [self atStartOfDayTimestamp:timestamp];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];
    return [self.class atEndOfDate:date];
}

+ (long long) atStartOfDate: (NSDate*) date {
    NSDate* d = [[NSCalendar currentCalendar] startOfDayForDate:date];
    return [d timeIntervalSince1970];
}

+ (long long) atEndOfDate: (NSDate*) date {
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.hour = -1;
    components.minute = -1;
    components.second = -1;
    return [[[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:NSCalendarWrapComponents] timeIntervalSince1970];
}

+ (float) getHour: (long long) timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger sec = [components second];
    float h = hour*1.0f + minute / 60.0f + sec / 3600.0f;
    return h;
}



/**
 Get Month of year by integer format "12 - 2018" -> 122018

 @param timestamp current time
 @return Int with formmat "mmyyyy"
 */
+ (NSInteger) getMonth:(long long)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    return components.month*10000 + components.year;
}


@end
