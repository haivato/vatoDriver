//
//  FCBookingService+BookStatus.m
//  FC
//
//  Created by Dung Vu on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCBookingService+BookStatus.h"

@implementation FCBookingService (BookStatus)
/*
 * Kiểm tra trạng thái "status" đã tồn tại trong list status của booking chưa
 * return:
 *  - YES nếu có
 *  - NO nếu không có
 */
- (BOOL) isExistStatus: (NSInteger) status {
    return [self isExistStatus:status
                          book:self.book];
}

- (BOOL) isExistStatus: (NSInteger) status
                  book: (FCBooking*) book{
    if (book.command.count > 0) {
        for (FCBookCommand* s in book.command) {
            if (s.status == status) {
                return YES;
            }
        }
    }
    
    return NO;
}

/*
 * Một booking hợp lệ phải thoả các điều kiện sau:
 * 1. Chưa có trạng thái kết thúc
 * 2. Thời gian tạo của booking (client write) không quá 5mins (tranh trường hợp khách book xong huỷ kết nối với app)
 */
- (BOOL) isBookingAvailable: (FCBooking*) book {
    if ([self isFinishedTrip:book]) {
        return NO;
    }
    
    return YES;
}

- (BOOL) isNewBook: (FCBooking*) book {
    FCBookCommand* stt = [book last];
    return stt.status == BookStatusClientCreateBook;
}

/**
 Trạng thái được xác đinh là đang trong chuyến đi thuộc danh sach sau:
 (chuyến đi đã bắt đầu (BookStatusStarted), tài xế đã chấp nhận chuyến và vào chuyến đi (BookStatusDriverAccepted),
 khách hàng đồng ý vào chuyến (BookStatusClientAgreed)
 
 @return YES nếu thoả mãn điều kiện trên.
 */

- (BOOL) isInTrip: (FCBooking*) book {
    FCBookCommand* currCmd = [book last];
    if (currCmd && [self isInTripWith:currCmd.status]) {
        for (int i = 0; i < book.command.count-1; i++) {
            FCBookCommand* cmd = [book.command objectAtIndex:i];
            if ([self isFinishedTripWith: cmd.status]) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL) isDeliveryFail: (FCBooking*) book {
    for (int i = 0; i < book.command.count; i++) {
        FCBookCommand* cmd = [book.command objectAtIndex:i];
        if ([self isBookStatuDeliveryFail: cmd.status]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isInTripWith: (NSInteger) status {
    return  status == BookStatusStarted ||
    status == BookStatusDriverAccepted ||
    status == BookStatusClientAgreed ||
    status == BookStatusDeliveryReceivePackageSuccess;
}

- (BOOL) isTripStarted: (FCBooking*) book {
    FCBookCommand* stt = [book last];
    if ([self isTripStartedWith:stt.status]) {
        for (int i = 0; i < book.command.count-1; i++) {
            FCBookCommand* cmd = [book.command objectAtIndex:i];
            if ([self isFinishedTripWith: cmd.status]) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL) isTripStartedWith: (NSInteger) status {
    return status == BookStatusStarted || status == BookStatusDeliveryReceivePackageSuccess;
}

- (BOOL) isTripCompleted: (FCBooking*) book {
    FCBookCommand* stt = [book last];
    return [self isTripCompletedWith:stt.status];
}

- (BOOL) isTripCompletedWith: (NSInteger) status {
    return status == BookStatusCompleted ||
    status == BookStatuDeliveryFail;
}

/**
 Trang thái được xác định là kết thúc một book phải thoả mãn trong danh sách sau:
 {hoan thanh, tai xe huy, khach hang huy, admin huy}
 
 @param status: trạng thái cần kiểm tra
 @return YES nếu thuộc danh sách trên. Ngược lại NO
 */

- (BOOL) isFinishedTrip: (FCBooking*) book {
    for (FCBookCommand* cmd in book.command) {
        if ([self isFinishedTripWith:cmd.status]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isFinishedTripWith: (NSInteger) status {
    if ([self isDriverCanceledWith:status] ||
        [self isClientCanceledWith:status] ||
        [self isTripCompletedWith:status] ||
        [self isAdminCanceledWith:status] ||
        [self isBookStatuDeliveryFail:status] )
        return YES;
    if (status == BookStatusOrderDriverGotTrip) {
        return YES;
    }
    return NO;
}

- (BOOL) isClientCancelInbook: (FCBooking*) book {
    FCBookCommand* stt = [book last];
    if (stt.status == BookStatusClientTimeout ||
        stt.status == BookStatusClientCancelInBook ) {
        return YES;
    }
    return NO;
}

- (BOOL) isClientCancelInbookWith: (NSInteger) status {
    return status == BookStatusClientTimeout ||
    status == BookStatusClientCancelInBook;
}

- (BOOL) isClientCancelIntrip: (FCBooking*) book {
    FCBookCommand* stt = [book last];
    return [self isClientCancelIntripWith:stt.status];
}

- (BOOL) isClientCancelIntripWith: (NSInteger) status {
    return status == BookStatusClientCancelIntrip;
}

- (BOOL) isClientCanceled: (FCBooking*) book {
    if ([self isClientCancelInbook: book] ||
        [self isClientCancelIntrip: book]) {
        return YES;
    }
    return NO;
}

- (BOOL) isClientCanceledWith: (NSInteger) status {
    return  [self isClientCancelInbookWith:status] ||
    [self isClientCancelIntripWith:status];
}

- (BOOL) isDriverCanceled: (FCBooking*) book {
    FCBookCommand* stt = [book last];
    return [self isDriverCanceledWith:stt.status];
}

- (BOOL) isDriverCanceledWith: (NSInteger) status {
    return (status == BookStatusDriverCancelInBook ||
            status == BookStatusDriverCancelIntrip ||
            status == BookStatusDriverDontEnoughMoney ||
            status == BookStatusDriverBusyInAnotherTrip ||
            status == BookStatusDriverMissing);
}

- (BOOL) isAdminCanceled: (FCBooking*) book {
    FCBookCommand* stt = [book last];
    return [self isAdminCanceledWith:stt.status];
}

- (BOOL) isAdminCanceledWith: (NSInteger) status {
    return (status == BookStatusAdminCancel);
}

- (BOOL) isBookStatuDeliveryFail: (NSInteger) status {
    return (status == BookStatuDeliveryFail);
}

- (BOOL) isBookStatusCompleted: (FCBooking*) book {
    FCBookCommand* stt = [book last];
    return (stt.status == BookStatusCompleted);
}

@end
