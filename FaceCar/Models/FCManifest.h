//
//  FCManifest.h
//  FC
//
//  Created by tony on 11/19/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import "FCModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCManifest : FCModel
@property(assign, nonatomic) NSInteger id;
@property(assign, nonatomic) BOOL active;
@property(assign, nonatomic) NSInteger type;
@property(strong, nonatomic) NSString* icon;
@property(strong, nonatomic) NSString* banner;
@property(strong, nonatomic) NSString* image;
@property(strong, nonatomic) NSString* title;
@property(strong, nonatomic) NSString* headline;
@property(strong, nonatomic) NSString* description;
@property(strong, nonatomic) NSString* code;
@property(assign, nonatomic) NSInteger createdAt;

@end

NS_ASSUME_NONNULL_END
