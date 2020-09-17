//
//  FCBookingService+PushTrip.h
//  FC
//
//  Created by Dung Vu on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCBookingService.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCBookingService (PushTrip)
- (NSDictionary*) getBookingBody: (FCBooking*) book;
- (void) apiCheckConnected: (FCBooking*) book;
- (void) apiCheckFinished:(FCBooking*)book;
@end

NS_ASSUME_NONNULL_END
