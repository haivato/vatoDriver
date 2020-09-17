//  File name   : NSArray+Extension.h
//
//  Author      : Dung Vu
//  Created date: 12/11/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

@import Foundation;



@interface NSArray<ObjectType> (Extension)

// Class's static constructors

// Class's constructors
- (ObjectType _Nullable) firstWhere:(BOOL(^)(ObjectType _Nonnull))condition;
- (void)forEach:(void(^)(ObjectType _Nonnull))block;
@end
