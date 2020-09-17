//
//  FCFavorite.h
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCFavorite : FCModel
@property(strong, nonatomic)  NSString* reporterFirebaseid;
@property(assign, nonatomic)  BOOL isFavorite;
@property(assign, nonatomic)  NSInteger userId;
@property(strong, nonatomic)  NSString* userFirebaseId;
@property(strong, nonatomic)  NSString* userAvatar;
@property(strong, nonatomic)  NSString* userPhone;
@property(strong, nonatomic)  NSString* userName;
@end
