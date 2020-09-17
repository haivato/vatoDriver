//
//  FirebaseDynamicLinkHelper.h
//  FC
//
//  Created by facecar on 7/12/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FirebaseDynamicLinkHelper : NSObject

+ (FirebaseDynamicLinkHelper*) shareInstance;

- (void) buildFDLLink: (NSString*) inviteCode complete: (void (^)(NSURL* link)) handler;
    
@end
