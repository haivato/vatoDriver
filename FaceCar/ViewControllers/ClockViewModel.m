//
//  ClockViewModel.m
//  FC
//
//  Created by facecar on 8/3/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "ClockViewModel.h"
#import "GoogleMapsHelper.h"

@implementation ClockViewModel {
    NSTimer* timer;
    FCBooking* booking;
}

- (instancetype) initClockForBook: (FCBooking*) book {
    self = [super init];
    booking = book;
    return self;
}

- (void) startClock {
    self.clock = [self getLastClock];
    if (!self.clock) {
        self.clock = [[FCDigitalClockTrip alloc] init];
    }
    
    [self startTimer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:NOTIFICATION_UPDATE_LOCATION
                                               object:nil];
}

- (void) stopClock {
    
    [self stopTimer];
    [self removeClock];
    self.clock = nil; // release
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_UPDATE_LOCATION
                                                  object:nil];
}

- (void) startTimer {
    [self stopTimer];
    
    double currentTime = [self getCurrentTimeStamp];
    NSInteger deltaSecond = (currentTime - self.clock.lastOnlineTime) / 1000;
    if (deltaSecond > 0 && self.clock.lastOnlineTime > 0)
    {
        self.clock.totalTime += deltaSecond;
    }
    
    self.clock.lastOnlineTime = currentTime;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(onTimeUpdate)
                                           userInfo:nil
                                            repeats:YES];
    [timer fire];
}

- (void) stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void) onTimeUpdate {
    self.clock.totalTime += 1;
    [self saveClock:self.clock];
    self.clock.lastOnlineTime = [self getCurrentTimeStamp];
    
    DLog(@"[Clock] Total time: %lu", (unsigned long)self.clock.totalTime);
}

- (void)locationUpdate:(NSNotification*)notification {
    CLLocation *location = notification.object;
    [self createRealPolyline:location];
    
    FCLocation *curLocation = [[FCLocation alloc] initWithLat:location.coordinate.latitude
                                                          lon:location.coordinate.longitude];
    
    if (self.clock.lastLocation) {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.clock.lastLocation.lat
                                                     longitude:self.clock.lastLocation.lon];
        CGFloat distance = [location distanceFromLocation:loc];
        self.clock.totalDistance += distance;
    }
    
    self.clock.lastLocation = curLocation;
    
    DLog(@"[Clock] Total distance: %f", self.clock.totalDistance);
}

- (void) createRealPolyline: (id) locations {
    
    // polyline
    NSMutableArray* listLocation = [[GoogleMapsHelper shareInstance] decodePolyline:self.clock.polyline];
    if (!listLocation) {
        listLocation = [[NSMutableArray alloc] init];
    }
    if ([locations isKindOfClass:[CLLocation class]]) {
        [listLocation addObject:locations];
    }
    else if ([locations isKindOfClass:[NSMutableArray class]]) {
        [listLocation addObjectsFromArray:locations];
    }
    
    self.clock.polyline = [[GoogleMapsHelper shareInstance] encodeStringWithCoordinates:listLocation];
    
    DLog(@"[Clock] Polyline: %@", self.clock.polyline)
}


#pragma mark - Cache data to local

- (void) saveClock:(FCDigitalClockTrip *)trip
{
    NSString* json = [trip toJSONString];
    [[NSUserDefaults standardUserDefaults] setObject:json forKey:[NSString stringWithFormat:@"latest_clock-%@", booking.info.tripId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) removeClock
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"latest_clock-%@", booking.info.tripId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (FCDigitalClockTrip*)getLastClock
{
    NSString* json = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"latest_clock-%@", booking.info.tripId]];
    FCDigitalClockTrip* trip = [[FCDigitalClockTrip alloc] initWithString:json error:nil];
    return trip;
}

+ (FCDigitalClockTrip*)getLastClock: (NSString*) tripid
{
    NSString* json = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"latest_clock-%@", tripid]];
    FCDigitalClockTrip* trip = [[FCDigitalClockTrip alloc] initWithString:json error:nil];
    return trip;
}

@end
