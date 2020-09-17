//
//  FCTransferMoney.h
//  FC
//
//  Created by facecar on 10/29/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCTransferMoney : FCModel
@property (strong, nonatomic) NSString* mobile;
@property (strong, nonatomic) NSString* pin;
@property (assign, nonatomic) NSInteger cash_amount;

@end
