//
//  FCMCarType.h
//  FaceCar
//
//  Created by Vu Dang on 6/11/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCMCarType;
@interface FCMCarType : FCModel
@property(assign, nonatomic) CGFloat punishment;
@property(assign, nonatomic) NSInteger groupId;
@property(assign, nonatomic) NSInteger id;
@property(strong, nonatomic) NSString* name;
@end
