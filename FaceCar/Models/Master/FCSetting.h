//
//  FCSetting.h
//  FaceCar
//
//  Created by Vu Dang on 6/29/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCSetting : FCModel

@property(assign, nonatomic) BOOL force;
@property(assign, nonatomic) BOOL isApply;
@property(assign, nonatomic) BOOL newest;
@property(strong, nonatomic) NSString* message;
@property(strong, nonatomic) NSString* ver;
@property(assign, nonatomic) NSInteger sortVer;

@property(strong, nonatomic) NSString* bundleIdentifier;
@property(strong, nonatomic) NSString* itunesURL;

@end
