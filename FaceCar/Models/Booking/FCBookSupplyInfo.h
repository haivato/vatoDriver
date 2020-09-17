//  File name   : FCBookSupplyInfo.h
//
//  Author      : Dung Vu
//  Created date: 4/6/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

@import Foundation;
#import "FCModel.h"

@interface FCBookSupplyInfo : FCModel
@property (copy, nonatomic) NSString<Optional> *productDescription;
@property (nonatomic) double estimatedPrice;
@end

