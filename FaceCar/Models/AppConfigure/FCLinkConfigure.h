//
//  FCLinkConfigure.h
//  FC
//
//  Created by facecar on 6/12/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCLinkConfigure;
@protocol TopupLinkConfigureProtocol;

@interface FCLinkConfigure : FCModel<TopupLinkConfigureProtocol>

@property (assign, nonatomic) BOOL active;
@property (assign, nonatomic) BOOL auth;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) NSInteger type; // 10: native , 20: webURL
@property (strong, nonatomic) NSString* iconURL;
@property (nonatomic, assign) NSInteger min;
@property (nonatomic, assign) NSInteger max;
@property (nonatomic, copy) NSArray<NSNumber *> * _Nullable options;
@end
