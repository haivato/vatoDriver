//
//  FCBanking.h
//  FC
//
//  Created by tony on 8/31/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCBanking;
@interface FCBanking : FCModel
@property (assign, nonatomic) NSInteger id;
@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) NSInteger max;
@property (assign, nonatomic) NSInteger min;
@property (assign, nonatomic) BOOL active;
@property (assign, nonatomic) BOOL chooseDefault;
@property (assign, nonatomic) NSInteger minimumBalance;
@property (strong, nonatomic) NSString* shortName;
@property (strong, nonatomic) NSString* icon;
@end
