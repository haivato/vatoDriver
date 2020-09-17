//
//  FCBookConfigure.h
//  FaceCar
//
//  Created by facecar on 4/20/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCBookConfigure : FCModel
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSString* message_in_peak_hours; // message gợi ý tăng giá giờ cao điểm
@property (assign, nonatomic) NSInteger distance_allow; // km
@property (assign, nonatomic) BOOL out_country;
@property (assign, nonatomic) BOOL hide_destination; // giau diem den
@property (assign, nonatomic) NSInteger price_maximum_multi;
@property (assign, nonatomic) NSInteger driver_request_booking_timeout; // timeout per one driver
@property (assign, nonatomic) double waiting_client_agree_timeout; // timeout per one driverwaiting_client_agree_timeout
@end
