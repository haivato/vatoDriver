//
//  AFNetworking+Helper.m
//  FC
//
//  Created by facecar on 11/14/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "AFHTTPSessionManager+Helper.h"

@implementation AFHTTPSessionManager (Helper)

- (NSURLSessionDataTask*)request:(NSString*)URLString
                          method:(NSString*) method
                      parameters:(id )parameters
                         success:(void (^)(id responseData))success
                         failure:(void (^)(id responseData, NSError* error))failure {
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method
                                                                   URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString]
                                                                  parameters:parameters
                                                                       error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:nil
                        downloadProgress:nil
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           if (error) {
                               if (failure) {
                                   NSLog(@"%@", [NSString stringWithFormat:@"%@", responseObject]);
                                   failure(responseObject, error);
                               }
                           } else {
                               if (success) {
                                   success(responseObject);
                               }
                           }
                       }];
    [dataTask resume];
    
    return dataTask;
}
@end
