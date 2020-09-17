//
//  FCBookingService+BookStatus.h
//  FC
//
//  Created by Dung Vu on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCBookingService.h"

@class FCBooking;
NS_ASSUME_NONNULL_BEGIN

@interface FCBookingService (BookStatus)
- (BOOL) isExistStatus: (NSInteger) status;
- (BOOL) isInTrip: (FCBooking*) book;
- (BOOL) isTripStarted: (FCBooking*) book;
- (BOOL) isTripCompleted: (FCBooking*) book;
- (BOOL) isClientCanceled: (FCBooking*) book;
- (BOOL) isDriverCanceled: (FCBooking*) book;
- (BOOL) isAdminCanceled: (FCBooking*) book;
- (BOOL) isNewBook: (FCBooking*) book;
- (BOOL) isFinishedTripWith: (NSInteger) status;
- (BOOL) isBookStatusCompleted: (FCBooking*) book;
/**
 Trang thái được xác định là kết thúc một book phải thoả mãn trong danh sách sau:
 {hoan thanh, tai xe huy, khach hang huy, admin huy}
 
 @param status: trạng thái cần kiểm tra
 @return YES nếu thuộc danh sách trên. Ngược lại NO
 */
- (BOOL) isFinishedTrip: (FCBooking*) book ;
/*
 * Một booking hợp lệ phải thoả các điều kiện sau:
 * 1. Chưa có trạng thái kết thúc
 * 2. Thời gian tạo của booking (client write) không quá 5mins (tranh trường hợp khách book xong huỷ kết nối với app)
 */
- (BOOL) isBookingAvailable: (FCBooking*) book;
- (BOOL) isDeliveryFail: (FCBooking*) book;

@end

NS_ASSUME_NONNULL_END
