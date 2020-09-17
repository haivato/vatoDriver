//
//  FCBookingService+UpdateStatus.h
//  FC
//
//  Created by Dung Vu on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCBookingService.h"

NS_ASSUME_NONNULL_BEGIN
@interface FCBookingService (UpdateStatus)
- (void) updateBookStatus: (NSInteger) status
                 complete: (void (^) (BOOL success)) complete;
- (void) updateBookStatus: (NSInteger) status
                     book: (FCBooking*) book
                 complete: (void (^) (BOOL success)) complete;
@end

NS_ASSUME_NONNULL_END
