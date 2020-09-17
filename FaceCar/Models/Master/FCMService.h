//
//  FCMService.h
//  FC
//
//  Created by facecar on 6/5/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCMService : FCModel
//@property (assign, nonatomic) NSInteger id;
@property (assign, nonatomic) NSInteger serviceId;
@property (assign, nonatomic) BOOL rank;
@property (assign, nonatomic) NSInteger type;
@property (copy, nonatomic) NSString* name;
@property (copy, nonatomic) NSString* displayName;
@property (assign, nonatomic) BOOL active;
@property (assign, nonatomic) BOOL enable;
@property (copy, nonatomic) NSString* transport;
@property (assign, nonatomic) BOOL force;

- (FCMService *)clone;
@end
