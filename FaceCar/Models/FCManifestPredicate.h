//
//  FCManifestPredicate.h
//  FC
//
//  Created by tony on 11/20/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import "FCModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCManifestPredicate : FCModel
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger manifestId;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy)   NSString *extra;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) NSInteger zoneId;
@property (nonatomic, assign) long long startDate;
@property (nonatomic, assign) long long endDate;
@property (nonatomic, assign) double startTime;
@property (nonatomic, assign) double endTime;
@property (nonatomic, assign) NSInteger times;
@property (nonatomic, assign) NSInteger timesPerDay;
@property (nonatomic, assign) NSInteger target;
@end

NS_ASSUME_NONNULL_END
