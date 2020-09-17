//
//  FCClient.h
//  FaceCar
//
//  Created by Vu Dang on 6/3/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"
@class FCUser;

@interface FCClient : FCModel
@property(strong, nonatomic) FCUser* user;
@property(assign, nonatomic) BOOL active;
@property(strong, nonatomic) NSString* version;
@property(strong, nonatomic) NSString* topic;
@property(assign, nonatomic) NSInteger created;
@property(strong, nonatomic) NSString* deviceToken;
@property(strong, nonatomic) NSString* photo;
@end
