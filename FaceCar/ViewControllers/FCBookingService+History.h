//
//  FCBookingService+History.h
//  FC
//
//  Created by Dung Vu on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCBookingService.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCBookingService (History)
- (void) saveBookToHistory:(FCBooking*) booking;
- (void) getListTripHistory:(void (^) (NSMutableArray* list)) callback;
- (void) removeTripHistory;
@end

NS_ASSUME_NONNULL_END
