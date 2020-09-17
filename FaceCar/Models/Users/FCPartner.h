//
//  FCPartner.h
//  FaceCar
//
//  Created by facecar on 12/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCPartner : FCModel

@property (strong, nonatomic) NSString* slogan;
@property (strong, nonatomic) NSString* fullname;
@property (strong, nonatomic) NSString* logo;
@property (strong, nonatomic) NSString* hotline;
@property (assign, nonatomic) NSInteger id;
@property (assign, nonatomic) NSInteger zone_id;
@property (assign, nonatomic) NSInteger group_id; // 20 is sedona

@end
