//
//  FCRouter.m
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCRouter.h"

@implementation FCRouter

- (id) init:(id)responseStr {
    self = [super init];
    if (self) {
        @try {
            id res = [[[[responseStr objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0];
            NSString* str = [[[[responseStr objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"overview_polyline"] objectForKey:@"points"];
            self.distance = [[[res objectForKey:@"distance"] objectForKey:@"value"] integerValue];
            self.distanceText = [[res objectForKey:@"distance"] objectForKey:@"text"];
            self.duration = [[[res objectForKey:@"duration"] objectForKey:@"value"] integerValue];
            self.durationText = [[res objectForKey:@"duration"] objectForKey:@"text"];
            self.polylineEncode = str;
            
        } @catch (NSException *exception) {
            DLog(@"Exception: %@", exception.reason)
        } @finally {
        }
    }
    return self;
}
@end
