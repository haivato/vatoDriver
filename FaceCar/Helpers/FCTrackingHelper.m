//
//  FCTrackingHelper.m
//  FC
//
//  Created by tony on 11/23/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import "FCTrackingHelper.h"
@import FirebaseAnalytics;
@implementation FCTrackingHelper

+ (void) trackEvent:(NSString *)name value:(NSDictionary *)value {
    [FIRAnalytics logEventWithName:name ?: @"" parameters:value ?: @{}];
}

@end
