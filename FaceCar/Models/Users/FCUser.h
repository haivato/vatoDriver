//
//  FCUser.h
//  FaceCar
//
//  Created by facecar on 5/10/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface FCUser : FCModel

@property(strong, nonatomic) NSString* avatarUrl;
@property(strong, nonatomic) NSString* email;
@property(strong, nonatomic) NSString* fullName;
@property(strong, nonatomic) NSString* nickname;
@property(assign, nonatomic) NSInteger id;
@property(strong, nonatomic) NSString* firebaseId;
@property(strong, nonatomic) NSString* phone;
@property(assign, nonatomic) NSInteger cash;
@property(assign, nonatomic) NSInteger coin;

- (NSString*) getDisplayName;

@end
