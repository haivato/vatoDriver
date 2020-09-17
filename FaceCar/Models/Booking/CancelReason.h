//
//  CancelReason.h
//  FC
//
//  Created by vato. on 2/8/20.
//  Copyright © 2020 Vato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CancelReason : FCModel

@property(nonatomic, assign) NSInteger id;
@property(nonatomic, copy) NSString<Optional> *message;
@end

