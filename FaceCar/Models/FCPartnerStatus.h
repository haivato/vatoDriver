//
//  FCPartnerStatus.h
//  FC
//
//  Created by facecar on 12/22/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCPartner.h"

@interface FCPartnerStatus : FCModel
@property (strong, nonatomic) FCPartner* partner;
@property (assign, nonatomic) NSInteger status;
@property (assign, nonatomic) NSInteger partner_id;

@end
