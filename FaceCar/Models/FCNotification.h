//
//  FCNotification.h
//  FC
//
//  Created by facecar on 7/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCNotification : FCModel

@property(nonatomic, strong) NSString*  title;
@property(nonatomic, strong) NSString*  body;
@property(nonatomic, strong) NSString*  id;
@property(nonatomic, strong) NSString*  url;
@property(nonatomic, assign) int status;
@property(nonatomic, assign) int type;
@property(nonatomic, strong) NSString*  referId;
@property(nonatomic, strong) NSString*  extra;
@property(nonatomic, strong) NSString*  bannerUrl;
@property(nonatomic, assign) long long  createdAt;

@end
