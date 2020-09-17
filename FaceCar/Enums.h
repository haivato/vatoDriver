//
//  Enums.h
//  FC
//
//  Created by facecar on 4/24/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#ifndef Enums_h
#define Enums_h

typedef enum : NSUInteger {
    BookStatusClientCreateBook = 11,
    BookStatusDriverAccepted = 12,
    BookStatusClientAgreed = 13,
    BookStatusStarted = 14, // chuyến đi bắt đầu
    BookStatusDeliveryReceivePackageSuccess = 15, // use for Express
    BookStatusCompleted = 21, // hoàn thành
    BookStatuDeliveryFail = 22, // use for Express
    BookStatusClientTimeout = 31,
    BookStatusClientCancelInBook = 32,
    BookStatusClientCancelIntrip = 33,
    BookStatusDriverCancelInBook = 41,
    BookStatusDriverDontEnoughMoney = 42,
    BookStatusDriverMissing = 43,
    BookStatusDriverBusyInAnotherTrip = 44, // driver in a another trip
    BookStatusDriverCancelIntrip = 45,
    BookStatusAdminCancel = 51,
    BookStatusOrderDriverGotTrip = 61,
    BookStatusTrackingReceiveTripAllow = 111 // only for tracking
} BookStatus;

typedef enum : NSUInteger {
    TripStatusStarted = 10,
    TripStatusCompleted = 20,
    TripStatusClientCanceled = 30,
    TripStatusDriverCanceled = 40,
    TripStatusAdminCanceled = 50
} TripStatus;

typedef enum : NSUInteger {
    TripEvaluateSuccess = 0,
    TripEvaluateSuspectDistance = 10, // chuyến đi nghi ngờ đi quá ngắn
    TripEvaluateSuspectDuration = 20, // chuyến đi nghi ngờ đi quá nhanh
    TripEvaluateSuspectDetalDistance = 30, // chuyến đi nghi ngờ tổng khoảng cách đi không đúng
    TripEvaluateSuspectDetalDuration = 40, // chuyến đi nghi ngờ tông thơi gian đi không đúng
    TripEvaluateSuspectSameAccount = 50,  // chuyến đi nghi ngờ book cùng tài khoản
    TripEvaluateSuspectSameLocation = 60,  // chuyến đi nghi ngờ book cùng vi trí
    TripEvaluateSuspectStartLocationOutOfRange = 71,
    TripEvaluateSuspectEndLocationOutOfRange = 72,
} TripEvaluate;

typedef enum : NSUInteger {
    NotifyTypeDefault = 10,
    NotifyTypeReferal = 20,
    NotifyTypePrmotion = 40,
    NotifyTypeBalance = 50,
    NotifyTypeTranferMoney = 60,
    NotifyTypeUpdateApp = 70,
    NotifyTypeChatting = 90, // new chat
    NotifyTypeNewBooking = 91, // new booking
    NotifyTypeManifest = 100,
    NotifyTypeLink = 110,
    NotifyNotEnoughVatoPay = 10000
} NotifyType;

typedef enum : NSUInteger {
    BookTypeFixed = 10, // book cố định
    BookTypeOneTouch = 20, // book 1 cham
    BookTypeDigital = 30 // đồng hồ điện tử
} BookType;

typedef enum : NSUInteger {
    VehicleTypeBike = 1024,
    VehicleTypeCar = 1,
    VehicleType7Seat = 2
} VehicleType;

typedef enum : NSInteger {
    VatoServiceCar = 1,
    VatoServiceCarPlus = 2,
    VatoServiceCar7 = 4,
    VatoServiceMoto = 8,
    VatoServiceMotoPlus = 16,
    VatoServiceFast4 = 32,
    VatoServiceFast7 = 64,
    VatoServiceExpress = 128,
    VatoServiceFood = 512,
    VatoServiceSupply = 1024
} VatoService;

typedef enum : NSInteger {
    LinkConfigureTypeCreateCar = 10,
    LinkConfigureTypeIDPage = 20,
    LinkConfigureTypeSummaryBonusPage = 21,
    LinkConfigureTypeTopup = 30,
    LinkConfigureTypeUpdateProfile = 40
} LinkConfigureType;

typedef enum : NSUInteger {
    FONT_CMND,
    BACK_CMND,
    AVATAR
} ImageType;

typedef enum : NSUInteger {
    DRIVER_UNREADY = 0,
    DRIVER_READY = 10,
    DRIVER_BUSY = 20
} OnlineStatus;

typedef enum : NSUInteger {
    UpdateViewTypeEmail = 10
} UpdateViewType;

typedef enum : NSInteger {
    DriverConfigTypeTranferMoney = 10,
    DriverConfigTypeWithdrawMoney = 11
} DriverConfigType;

typedef enum : NSInteger {
    PaymentMethodCash = 0,
    PaymentMethodVATOPay = 1,
    PaymentMethodAll = 2,
    PaymentMethodVisa = 3,
    PaymentMethodMastercard = 4,
    PaymentMethodATM = 5,
    PaymentMethodMomo = 6,
    PaymentMethodZaloPay = 7
} PaymentMethod;

typedef enum : NSInteger {
    INITIAL = 100,
    TRANSFERRED_MANUALLY = 200,
    TRANSFERRED_SEMI_AUTOMATIC = 250,
    REJECTED_MANUALLY = 300,
    REJECTED_SEMI_AUTOMATIC = 350
} WithdrawOrderStatus;

typedef enum : NSUInteger {
    TransReferTypeTrip = 100, // các giao dịch liên quan tới chuyến đi
    TransReferTypeTopup = 40001, // các giao dịch liên quan tộp tiền
    TransReferTypeWithdraw = 50001, // các giao dịch liên quan tới rút tiền
    TransReferTypeTransfer = 60001, // các giao dịch liên quan tới chuyển tiền
    TransReferTypeConver = 70001 // các giao dịch liên quan tới duyệt tiền chờ duyệt
} TransReferType;

typedef enum: NSUInteger {
    
    REVERT = 2 ,  // giao dịch hoàn cho 1 giao dịch khác
    TRIP_DRIVER_SUPPORT = 401 ,  // giao dịch thưởng lái xe
    TRIP_DRIVER_SUPPORT_REVERT = 402 ,  // hoàn giao dịch thưởng lái xe
    TRIP_CLIENT_SUPPORT_TO_CLIENT = 411 ,  // giao dịch khuyến mãi khách hàng trả cho khách hàng
    TRIP_CLIENT_SUPPORT_TO_DRIVER = 413 ,  // giao dịch khuyến mãi khách hàng trả cho lái xe
    TRIP_CLIENT_SUPPORT_TO_CLIENT_REVERT = 412 ,  // hoàn giao dịch khuyến mãi khách hàng trả cho khách hàng
    TRIP_CLIENT_SUPPORT_TO_DRIVER_REVERT = 414 ,  // hoàn giao dịch khuyến mãi khách hàng trả cho lái xe
    TRIP_FEE = 80000 ,  // giao dịch thu phí hoa hồng
    TRIP_FEE_REVERT = 80002 ,  // hoàn giao dịch thu phí hoa hồng
    TRIP_FARE = 70000 ,  // giao dịch phí chuyến đi trả cho lái xe
    TRIP_FARE_REVERT = 70002 ,  // hoàn giao dịch phí chuyến đi trả cho lái xe
    TRIP_FARE_CAPTURE = 70001 ,  // giao dịch phí chuyến đi thu của kháchhàng
    TRIP_FARE_CAPTURE_REVERT = 70003 ,  // hoàn giao dịch phí chuyến đi thu của khách hàng
    
    TRIP_TAX = 80003, // giao dịch thu thuế doanh thu chuyến đi
    TRIP_TAX_REVERT = 80004, // hoàn giao dịch thu thuế
    TRIP_DRIVER_SUPPORT_TAX = 80005, // giao dịch thu thuế thưởng láixe
    TRIP_DRIVER_SUPPORT_TAX_REVERT = 80006, // hoàn giao dịch thu thuếthưởng lái xe
    BONUS_DRIVER = 80008, // giao dịch thưởng lái xe liên quan tớidoanh thu
    BONUS_DRIVER_REVERT = 80009, // hoàn giao dịch thưởng lái xe liênquan tới doanh thu
    BONUS_DRIVER_TAX = 80010, // giao dịch thu thuế thưởng lái xe liênquan tới doanh thu
    BONUS_DRIVER_TAX_REVERT = 80011, // hoàn giao dịch thu thuế thưởng lái xeliên quan tới doanh thu
    BONUS_OTHER = 80012, // giao dịch thưởng lái xe khác
    BONUS_OTHER_REVERT = 80013, // hoàn giao dịch thưởng lái xe khác
    BONUS_OTHER_TAX = 80014, // giao dịch thưởng lái xe khác
    BONUS_OTHER_TAX_REVERT = 80015, // giao dịch thưởng lái xe khác
    
    TRANSFER_ADMIN_I = 90001 ,  // giao dịch chuyển tiền admin
    TRANSFER_ADMIN_O = 90002 ,  // giao dịch chuyển tiền admin
    TRANSFER_I = 90003 ,  // giao dịch chuyển tiền (trạm chuyển hoặc tự chuyển từ tiền mặt qua tín dụng)
    TRANSFER_O = 90004 ,  // giao dịch chuyển tiền (trạm chuyển hoặc tự chuyển từ tiền mặt qua tín dụng)
    TOPUP_NAPAS = 100001 ,  // giao dịch nạp tiền từ napas
    TOPUP_ZALOPAY = 100002 ,  // giao dịch nạp tiền từ zalo pay
    TOPUP_OTHER = 100003 ,  // giao dịch nạp tiền khác
    WITHDRAW_AGRIBANK_I = 20001 ,  // giao dịch rút tiền qua Agribank
    WITHDRAW_AGRIBANK_O = 20002 ,  // giao dịch hủy rút tiền qua Agribank
    WITHDRAW_VIETINBANK_I = 20003 ,  // giao dịch rút tiền qua Vietinbank
    WITHDRAW_VIETINBANK_O = 20004 ,  // giao dịch hủy rút tiền quaVietinbank
    WITHDRAW_VATO_OFFICE = 20005 ,  // giao dịch rút tiền qua văn phòng VATO
    CONVERT_DRIVER_SUPPORT_I = 300001 ,  // giao dịch duyệt thưởng lái xe
    CONVERT_DRIVER_SUPPORT_O = 300002 ,  // giao dịch duyệt thưởng lái xe
    CONVERT_DRIVER_SUPPORT_REJECT = 300003 ,  // giao dịch từ chối duyệt thưởng lái xe
    CONVERT_CLIENT_SUPPORT_I = 300004 ,  // giao dịch duyệt khuyến mãi khách hàng
    CONVERT_CLIENT_SUPPORT_O = 300005  // giao dịch duyệt khuyến mãi khách hàng
} TransType;

#endif /* Enums_h */
