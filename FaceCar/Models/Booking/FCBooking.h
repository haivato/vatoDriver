//
//  FCBooking.h
//  FC
//
//  Created by facecar on 4/29/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCBookCommand.h"
#import "FCBookTracking.h"
#import "FCBookInfo.h"
#import "FCBookEstimate.h"
#import "FCBookExtra.h"
#import "FCBookExtraData.h"

@interface FCBooking : FCModel

@property (strong, nonatomic) FCBookInfo* info;
@property (strong, nonatomic) NSArray<Ignore>* command;
@property (strong, nonatomic) NSArray<Ignore>* tracking;
@property (strong, nonatomic) FCBookEstimate* estimate;
@property (strong, nonatomic) FCBookExtra* extra;
@property (strong, nonatomic) FCBookExtraData<Optional>* extraData;
@property (copy, nonatomic) NSString<Optional> *last_command;

- (BOOL)deliveryMode;
- (FCBookCommand *)last;
- (NSDictionary *)getCommandDict;
- (NSDictionary*) getTrackingDict;
- (BOOL)validEstimate;
- (BOOL)deliveryFoodMode;
- (NSInteger)getPriceOderFood;
- (NSInteger)getShipFeeOderFood;
- (NSInteger)getTotalPriceOderFood;
- (NSInteger)getTotalPriceClientPay;
- (NSInteger)getMerchantFinalPrice;
- (NSInteger)getDriverRevenue;
- (NSInteger)getTotalPromotionFood;
- (NSInteger)discountVato;
@end
