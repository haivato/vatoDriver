//
//  FCResponse.h
//  FaceCar
//
//  Created by facecar on 5/10/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface FCResponse : FCModel
@property (assign, nonatomic) NSInteger status;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSDictionary<Ignore>* data;
@end
