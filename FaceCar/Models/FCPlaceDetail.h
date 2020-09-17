//
//  FCPlaceSearch.h
//  FC
//
//  Created by tony on 4/19/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCPlaceDetail : FCModel
@property(strong, nonatomic) NSString* fullAddress;
@property(strong, nonatomic) FCLocation* location;
@end

NS_ASSUME_NONNULL_END
