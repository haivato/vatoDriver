//
//  AFNetworking+Helper.h
//  FC
//
//  Created by facecar on 11/14/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFHTTPSessionManager (Helper)

- (NSURLSessionDataTask *_Nullable)request:(NSString*_Nonnull) URLString
                                    method:(NSString*_Nonnull) method
                                parameters:(id _Nonnull) parameters
                                   success:(void (^_Nullable)(id _Nullable responseData)) success
                                   failure:(void (^_Nullable)(id _Nullable responseData, NSError * _Nonnull error)) failure;

@end
