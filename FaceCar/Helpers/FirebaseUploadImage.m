//
//  FirebaseUploadImage.m
//  FC
//
//  Created by vato. on 8/22/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FirebaseUploadImage.h"
#import "FirebaseHelper.h"

@implementation FirebaseUploadImage
+ (void)upload: (NSArray<UIImage *> * _Nonnull)images withPath: (NSString *_Nonnull)path completeHandler:(void(^)(NSArray<NSURL *> *urls, NSError *_Nullable error)) handler {
    [[FirebaseHelper shareInstance] upload:images withPath:path completeHandler:handler];
}
@end
