//
//  FCGift.h
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCGift;

@interface FCGift : FCModel

@property(assign, nonatomic) NSInteger id;
@property(strong, nonatomic) NSString* code;
@property(assign, nonatomic) BOOL active;
@property(assign, nonatomic) long long start;
@property(assign, nonatomic) long long end;
@property(assign, nonatomic) NSInteger amount_seed;
@property(assign, nonatomic) NSInteger amount_seed_max;
@property(assign, nonatomic) NSInteger type;
@property(assign, nonatomic) NSInteger unit;
@property(strong, nonatomic) NSString* banner_url;
@property(strong, nonatomic) NSString* description;
@property(strong, nonatomic) NSString* seo_url;
@property(assign, nonatomic) NSInteger zone_id;
@property(assign, nonatomic) NSInteger max_apply;
@property(assign, nonatomic) NSInteger counter;
@property(assign, nonatomic) NSInteger activated_codes;
@property(assign, nonatomic) NSInteger number_of_applied;
@property(assign, nonatomic) NSInteger strategy; // event type

- (NSInteger) getAmountPromotion: (NSInteger) originPrice;

@end
