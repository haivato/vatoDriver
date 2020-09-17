//
//  FCTripBook.h
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCPlace.h"
#import "FCDigitalClockTrip.h"
#import "FCBookTracking.h"
#import "FCGift.h"

@interface FCTripBook : FCModel

@property(nonatomic, assign) long long  requestId;
@property(nonatomic, strong) NSString*  bookingId;
@property(nonatomic, assign) NSInteger  salePrice; // gia goc vivu
@property(nonatomic, assign) NSInteger  bookPrice; // gia khach dat
@property(nonatomic, assign) NSInteger  clientPrice; // gia khach nhập
@property(nonatomic, assign) NSInteger  stationTip; // tien bo cho station
@property(nonatomic, assign) NSInteger  promotionValue; // tien khuyen mai`
@property(nonatomic, strong) NSString*  promotionCode;
@property(nonatomic, assign) NSInteger  promotionEventId;
@property(nonatomic, strong) FCClient*  client;
@property(nonatomic, strong) FCDriver*  driver;
@property(nonatomic, strong) FCPlace*  start; // toa độ đón
@property(nonatomic, strong) FCPlace*  end; // toạ độ dich
@property(nonatomic, strong) FCMCarType*  service;
@property(nonatomic, strong) FCGift*  promotion;
@property(nonatomic, strong) NSString*  contactPhone;
@property(nonatomic, assign) NSInteger  status;
@property(nonatomic, assign) NSInteger  lastStatus;
@property(nonatomic, assign) NSInteger  bookType;
@property(nonatomic, assign) NSInteger  distance;
@property(nonatomic, assign) NSInteger  duration;
@property(nonatomic, assign) NSInteger  userType;
@property(nonatomic, assign) long long  created;
@property(nonatomic, assign) double  stationFee; // phí vivu áp dụng cho station trên tiền chênh lêch book
@property(nonatomic, assign) double  stationCommission; // % hoa hồng station nhân đươc trên giá gốc chuyến đi
@property(nonatomic, strong) FCBookTracking* trackingStatus;

@end
