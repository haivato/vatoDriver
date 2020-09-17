//
//  FCBookingRule.h
//  FC
//
//  Created by facecar on 5/29/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCBookingRule : FCModel

/**
 Khoảng cách tối thiểu cho phép chuyến đi được thực hiện, được tính bằng meter
 Nếu bé hơn giá trị này -> chuyến nghi ngờ
 */
@property (assign, nonatomic) NSInteger distance;


/**
 Thời gian tối thiểu cho phép chuyến đi được thực hiện, được tính bằng phút
 Nếu bé hơn gía trị này -> chuyến bị nghi ngờ
 */
@property (assign, nonatomic) NSInteger duration;

/**
 Chênh lêch khoảng cách thực tế và dự tính tối thiểu cho phép
 Được tính bằng % ( vidu 30%)
 */
@property (assign, nonatomic) NSInteger delta_distance;

/**
 Chênh lêch thời gian thực tế và dự tính tối thiểu cho phép
 Được tính bằng % ( vidu 30%)
 */
@property (assign, nonatomic) NSInteger delta_duration;


/**
 Cho phép book xe với cùng số điện thoại không
 Nếu False -> chuyến nghi tôi
 */
@property (assign, nonatomic) BOOL same_phone;


/**
 Khoảng cách tối thiểu cho phép nhận chuyến giữa txe và khách khi book xe
 Nếu khoảng cách thực tế của khách hàng và txe nhỏ hơn giá trị này thì chuyến đi được đánh giấu nghi ngờ
 */
@property (assign, nonatomic) NSInteger distance_receive;

/**
 Bán kính cho phép bắt đầu chuyến
 */
@property (assign, nonatomic) NSInteger start_radius;

/**
 Bán kính cho phép kết thúc chuyến
 */
@property (assign, nonatomic) NSInteger end_radius;

@end
