//
//  FCGGPlace.h
//  FaceCar
//
//  Created by facecar on 4/4/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCGGPlace : FCModel

@property (strong, nonatomic) NSString* description; // name of address
@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSString* place_id;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* address;
@end
