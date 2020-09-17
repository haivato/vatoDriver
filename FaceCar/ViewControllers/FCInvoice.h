//
//  FCInvoice.h
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCInvoice;
@interface FCInvoice : FCModel

@property (assign, nonatomic) long long id;
@property (assign, nonatomic) long long transactionDate;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSString* referId;
@property (assign, nonatomic) NSInteger before;
@property (assign, nonatomic) NSInteger after;
@property (assign, nonatomic) NSInteger amount;
@property (assign, nonatomic) NSInteger type;
@property (assign, nonatomic) NSInteger status;
@property (assign, nonatomic) NSInteger accountFrom;
@property (assign, nonatomic) NSInteger accountTo;
@property (assign, nonatomic) NSInteger toAfterCoinP;

- (NSString*) titleTransaction;
@end
