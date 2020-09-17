//
//  FCInvoice.m
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCInvoice.h"

@implementation FCInvoice
@synthesize description;

- (NSString*) titleTransaction {
    NSString* title = @"";
    switch (self.type) {
        case REVERT:  // giao dịch hoàn cho 1 giao dịch khác
            title = @"Hoàn tiền";
            break;
            
        case TRIP_DRIVER_SUPPORT:  // giao dịch thưởng lái xe
            title = @"Thưởng";
            break;
        case TRIP_DRIVER_SUPPORT_REVERT: // hoàn giao dịch thưởng lái xe
            title = @"Hoàn tiền";
            break;
        case TRIP_CLIENT_SUPPORT_TO_CLIENT: // giao dịch khuyến mãi khách hàng trả cho khách hàng
            title = @"Khuyến mãi";
            break;
        case TRIP_CLIENT_SUPPORT_TO_DRIVER:// giao dịch khuyến mãi khách hàng trả cho lái xe
            title = @"Khuyến mãi";
            break;
        case TRIP_CLIENT_SUPPORT_TO_CLIENT_REVERT: // hoàn giao dịch khuyến mãi khách hàng trả cho khách hàng
            
            break;
        case TRIP_CLIENT_SUPPORT_TO_DRIVER_REVERT:// hoàn giao dịch khuyến mãi khách hàng trả cho lái xe
            
            break;
        case TRIP_FEE: // giao dịch thu phí hoa hồng
            
            break;
        case TRIP_FEE_REVERT:// hoàn giao dịch thu phí hoa hồng
            
            break;
        case TRIP_FARE:// giao dịch phí chuyến đi trả cho lái xe
            
            break;
        case TRIP_FARE_REVERT:// hoàn giao dịch phí chuyến đi trả cho lái xe
            
            break;
        case TRIP_FARE_CAPTURE:  // giao dịch phí chuyến đi thu của kháchhàng
            
            break;
        case TRIP_FARE_CAPTURE_REVERT:  // hoàn giao dịch phí chuyến đi thu của khách hàng
            
            break;
        case TRANSFER_ADMIN_I:  // giao dịch chuyển tiền admin
            
            break;
        case TRANSFER_ADMIN_O:  // giao dịch chuyển tiền admin
            
            break;
        case TRANSFER_I:  // giao dịch chuyển tiền (trạm chuyển hoặc tự chuyển từ tiền mặt qua tín dụng)
            
            break;
        case TRANSFER_O:  // giao dịch chuyển tiền (trạm chuyển hoặc tự chuyển từ tiền mặt qua tín dụng)
            
            break;
        case TOPUP_NAPAS:  // giao dịch nạp tiền từ napas
            
            break;
        case TOPUP_ZALOPAY:  // giao dịch nạp tiền từ zalo pay
            
            break;
        case TOPUP_OTHER:  // giao dịch nạp tiền khác
            
            break;
        case WITHDRAW_AGRIBANK_I:  // giao dịch rút tiền qua Agribank
            
            break;
        case WITHDRAW_AGRIBANK_O:  // giao dịch hủy rút tiền qua Agribank
            
            break;
        case WITHDRAW_VIETINBANK_I:  // giao dịch rút tiền qua Vietinbank
            
            break;
        case WITHDRAW_VIETINBANK_O:  // giao dịch hủy rút tiền quaVietinbank
            
            break;
        case WITHDRAW_VATO_OFFICE:  // giao dịch rút tiền qua văn phòng VATO
            
            break;
        case CONVERT_DRIVER_SUPPORT_I:  // giao dịch duyệt thưởng lái xe
            
            break;
        case CONVERT_DRIVER_SUPPORT_O:  // giao dịch duyệt thưởng lái xe
            
            break;
        case CONVERT_DRIVER_SUPPORT_REJECT:  // giao dịch từ chối duyệt thưởng lái xe
            
            break;
        case CONVERT_CLIENT_SUPPORT_I:  // giao dịch duyệt khuyến mãi khách hàng
            
            break;
        case CONVERT_CLIENT_SUPPORT_O:  // giao dịch duyệt khuyến mãi khách hàng
            
            break;
    }
    
    return title;
}

@end
