//
//  FCBookCommand.m
//  FC
//
//  Created by facecar on 4/24/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBookCommand.h"

@implementation FCBookCommand

- (BOOL)isEqual:(id)object {
    FCBookCommand *obj2 = [FCBookCommand castFrom:object];
    if (!obj2) { return NO; }
    return _status == obj2.status;
}

- (BOOL)isDriverStatus {
    if (self.status == BookStatusDriverAccepted ||
        self.status == BookStatusStarted ||
        self.status == BookStatusDeliveryReceivePackageSuccess ||
        self.status == BookStatusCompleted ||
        self.status == BookStatuDeliveryFail ||
        self.status == BookStatusDriverCancelInBook ||
        self.status == BookStatusDriverDontEnoughMoney ||
        self.status == BookStatusDriverMissing ||
        self.status == BookStatusDriverBusyInAnotherTrip ||
        self.status == BookStatusDriverCancelIntrip ||
        self.status == BookStatusTrackingReceiveTripAllow) {
        return true;
    }
    return false;
}
    
@end
