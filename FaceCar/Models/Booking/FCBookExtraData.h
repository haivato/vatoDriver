//
//  FCBookExtraData.h
//  FC
//
//  Created by admin on 6/5/20.
//  Copyright © 2020 Vato. All rights reserved.
//

#import "FCModel.h"

@interface FCBookExtraData : FCModel
@property (assign, nonatomic) double partnerTipping;
@property (copy, nonatomic) NSString<Optional>* partnerTippingName;

@end
