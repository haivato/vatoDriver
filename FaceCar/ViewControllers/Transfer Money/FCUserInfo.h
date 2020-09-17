//
//  FCUserInfo.h
//  FC
//
//  Created by facecar on 10/29/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCUserInfo : FCModel
@property (assign, nonatomic) NSInteger id;
@property (strong, nonatomic) NSString* firebaseId;
@property (strong, nonatomic) NSString* phoneNumber;
@property (strong, nonatomic) NSString* fullName;
@property (strong, nonatomic) NSString* avatar;
@end
