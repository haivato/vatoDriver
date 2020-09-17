//
//  FCChat.h
//  FaceCar
//
//  Created by facecar on 3/1/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCChat : FCModel

@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSString* sender;
@property (strong, nonatomic) NSString* receiver;
@property (assign, nonatomic) long long id;
@property (assign, nonatomic) long long time;
@end
