//
//  FCWayPoint.h
//  FC
//
//  Created by khoi tran on 4/8/20.
//  Copyright © 2020 Vato. All rights reserved.
//

#import "FCModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCWayPoint : FCModel
@property(nonatomic, strong) NSString*  address;
@property(nonatomic, strong) NSString<Optional>*  name;
@property(assign, nonatomic) double lat;
@property(assign, nonatomic) double lon;


@end

NS_ASSUME_NONNULL_END
