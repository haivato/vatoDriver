//
//  FCBookClientRequest.h
//  FC
//
//  Created by facecar on 4/29/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCGift.h"
#import "Enums.h"
#import "FCBookEstimate.h"
#import "CancelReason.h"
#import "FCBookSupplyInfo.h"

@interface FCBookInfo : FCModel

@property(nonatomic, assign) long long  timestamp;
@property(nonatomic, strong) NSString*  tripId;
@property(nonatomic, strong) NSString<Optional>*  requestId;
@property(nonatomic, strong) NSString*  tripCode;
@property(nonatomic, assign) NSInteger  price;
@property(nonatomic, assign) NSInteger  additionPrice;
@property(nonatomic, strong) NSString*  clientFirebaseId;
@property(nonatomic, assign) NSInteger  clientUserId;
@property(nonatomic, strong) NSString*  driverFirebaseId;
@property(nonatomic, assign) NSInteger  driverUserId;
@property(nonatomic, strong) NSString*  contactPhone;
@property(nonatomic, assign) NSInteger  tripType;
@property(nonatomic, assign) NSInteger  distance;
@property(nonatomic, assign) NSInteger  duration;
@property(nonatomic, assign) long long  vehicleId;
@property(nonatomic, strong) NSString*  note;
@property(nonatomic, strong) FCBookSupplyInfo<Optional>* supplyInfo;
// start place
@property(strong, nonatomic) NSString* startName;
@property(strong, nonatomic) NSString* startAddress;
@property(assign, nonatomic) double startLat;
@property(assign, nonatomic) double startLon;
@property(assign, nonatomic) NSInteger zoneId;

// end place
@property(strong, nonatomic) NSString* endName;
@property(strong, nonatomic) NSString* endAddress;
@property(assign, nonatomic) double endLat;
@property(assign, nonatomic) double endLon;

// service
@property(assign, nonatomic) NSInteger serviceId;
@property(strong, nonatomic) NSString* serviceName;

// fare
@property(assign, nonatomic) NSInteger modifierId;
@property(assign, nonatomic) NSInteger farePrice;
@property(assign, nonatomic) NSInteger fareClientSupport;
@property(assign, nonatomic) NSInteger fareDriverSupport;

// promotion
@property(nonatomic, assign) NSInteger  promotionValue;
@property(nonatomic, copy) NSString*  promotionCode;
@property(nonatomic, assign) NSInteger  promotionModifierId;
@property(nonatomic, assign) NSInteger  promotionDelta;
@property(nonatomic, assign) CGFloat  promotionRatio;
@property(nonatomic, assign) NSInteger  promotionMin;
@property(nonatomic, assign) NSInteger  promotionMax;
@property(nonatomic, copy) NSString*  promotionToken;
@property(nonatomic, copy) NSString*  promotionDescription;
@property(nonatomic, assign) NSInteger  vatoDiscountShippingFee;
@property(nonatomic, assign) NSInteger  discountAmount;

@property(nonatomic, strong) NSArray<Optional>* receiveImages;
@property(nonatomic, strong) NSArray<Optional>* deliverImages;
@property(nonatomic, strong) NSArray<Optional>* delivery_fail_images;
@property(nonatomic, strong) NSArray<Optional>* deliveryFailImages;
//deliveryFailImages

@property(nonatomic, strong) NSString<Optional>* senderName;
@property(nonatomic, strong) NSString<Optional>* senderPhone;
@property(nonatomic, strong) NSString<Optional>* receiverName;
@property(nonatomic, strong) NSString<Optional>* receiverPhone;
@property(nonatomic, assign) NSInteger end_reason_id;
@property(nonatomic, copy) NSString<Optional> *end_reason_value;
@property(strong, nonatomic) CancelReason<Optional>* driver_cancel_intrip;

// payment method
@property(assign, nonatomic) PaymentMethod payment;
@property(nonatomic, strong) NSString<Ignore> *cardId;

@property(nonatomic, strong) NSString<Optional>* embeddedPayload;

// finish info
@property(nonatomic, assign) long long receivedAt;// Thời điểm nhận chuyến
@property(nonatomic, assign) long long startedAt;  // Thời điểm bắt đầu chuyến
@property(nonatomic, assign) long long finishedAt; // Thời điểm kết thúc chuyến
@property(nonatomic, assign) double driverFinishLocationLat; // Vị trí kết thúc chuyến của tài xế.
@property(nonatomic, assign) double driverFinishLocationLon;
@property(nonatomic, assign) double driverStartLocationLat; // Vị trí bắt đầu chuyến của tài xế.
@property(nonatomic, assign) double driverStartLocationLon;
@property(nonatomic, assign) double driverAcceptLocationLat; // Vị trí nhận chuyến của tài xế.
@property(nonatomic, assign) double driverAcceptLocationLon;
@property(nonatomic, assign) long long estimatedReceiveDuration; // Ước tính thời gian đón.
@property(nonatomic, assign) long long estimatedReceiveDistance; // Ước tính khoảng cách đón.
@property(nonatomic, assign) long long estimatedIntripDuration; // Ước tính thời gian trả khách
@property(nonatomic, assign) long long estimatedIntripDistance; // Ước tính khoảng cách thực hiện chuyến
@property(nonatomic, assign) long long actualReceiveDuration; // Thực tế thời gian đón.
@property(nonatomic, assign) long long actualReceiveDistance; // Thực tế khoảng cách đón.
@property(nonatomic, assign) long long actualIntripDuration; // Thực tế thời gian trả khách
@property(nonatomic, assign) long long actualIntripDistance; // Thực tế khoảng cách thực hiện
@property(nonatomic, assign) long long startFavoritePlaceId;
@property(nonatomic, assign) long long endFavoritePlaceId;

@property(nonatomic, strong) NSArray<Optional>*  wayPoints;

- (NSInteger) getBookPrice;
- (NSInteger) getType;

- (void) updateInfo:(NSArray*) tracking estimate:(FCBookEstimate*) estimate andLocation: (CLLocation*) location;

- (void) updateInfoReceiveImages:(NSArray*) receiveImages;
- (void) updateInfoDeliverImages:(NSArray*) deliverImages;
- (BOOL)deliveryMode;
- (BOOL)foodMode;
- (NSString *)localizeServiceName;
- (NSInteger)getTotalPriceOderFood;
- (NSString *)supplyNote;
- (NSString *)noteTrip;
- (UIImage *)getIConService;
- (NSInteger)getDiscountAmount;
@end
