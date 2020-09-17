//
//  FCMInvite.h
//  FaceCar
//
//  Created by facecar on 3/28/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCMInvite : FCModel

@property (assign, nonatomic) NSInteger id;
@property (assign, nonatomic) BOOL enable;
@property (strong, nonatomic) NSString* body;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* icon_ref;
@property (strong, nonatomic) NSString* href;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSString* campaign_url;


@end
