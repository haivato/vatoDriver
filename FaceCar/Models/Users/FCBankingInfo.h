//
//  FCBankingInfo.h
//  FC
//
//  Created by tony on 8/31/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCBankingInfo : FCModel
@property (strong, nonatomic) NSString* bank;
@property (strong, nonatomic) NSString* bankBranch;
@property (strong, nonatomic) NSString* bankAccount;
@property (strong, nonatomic) NSString* accountName;
@property (strong, nonatomic) NSString* bankNote;
@property (assign, nonatomic) NSInteger amount;

@end
