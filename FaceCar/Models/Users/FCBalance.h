//
//  FCBalance.h
//  FC
//
//  Created by facecar on 6/2/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCBalance : FCModel
@property (assign, nonatomic) NSInteger credit; // tín dụng
@property (assign, nonatomic) NSInteger creditPending; // tín dụng chờ duyệt
@property (assign, nonatomic) NSInteger hardCash; // tiền mặt
@property (assign, nonatomic) NSInteger hardCashPending; // tiền mặt chờ duyệt
@end
