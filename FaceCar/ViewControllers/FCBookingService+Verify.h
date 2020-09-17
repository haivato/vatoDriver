//
//  FCBookingService+Verify.h
//  FC
//
//  Created by Dung Vu on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCBookingService.h"
@class FCBooking;
NS_ASSUME_NONNULL_BEGIN

@interface FCBookingService (Verify)
- (NSDictionary*) getTripStatusDict: (FCBooking*) book;
- (NSDictionary*) getTripStatusDetailDict: (FCBooking*) book;
- (NSDictionary*) getTripEvalution: (FCBooking*) book;
- (BOOL) isStartLocationOutOfRange: (FCBooking*) book;
- (BOOL) isEndLocationOutOfRange: (FCBooking*) book;
@end

NS_ASSUME_NONNULL_END
