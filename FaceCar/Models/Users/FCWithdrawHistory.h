//
//  FCWithdrawHistory.h
//  FC
//
//  Created by tony on 9/2/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCWithdrawHistory : FCModel
@property (strong, nonatomic) NSString* accountName;
@property (assign, nonatomic) NSInteger amount;
@property (strong, nonatomic) NSString* bank;
@property (strong, nonatomic) NSString* bankAccount;
@property (strong, nonatomic) NSString* bankBranch;
@property (strong, nonatomic) NSString* bankNote;
@property (strong, nonatomic) NSString* code;
@property (assign, nonatomic) long long createdAt;
@property (assign, nonatomic) long long id;
@property (assign, nonatomic) NSInteger status;
@end
