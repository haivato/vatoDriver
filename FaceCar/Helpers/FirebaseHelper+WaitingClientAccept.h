//
//  FirebaseHelper+WaitingClientAccept.h
//  FC
//
//  Created by Dung Vu on 9/23/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FirebaseHelper.h"

@class RACSignal;
NS_ASSUME_NONNULL_BEGIN

@interface FirebaseHelper (WaitingClientAccept)
- (RACSignal *)trackAcceptClient:(FCBooking *)book timeout:(NSTimeInterval)timeout;
@end

NS_ASSUME_NONNULL_END
