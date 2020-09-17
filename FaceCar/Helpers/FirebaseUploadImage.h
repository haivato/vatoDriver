//
//  FirebaseUploadImage.h
//  FC
//
//  Created by vato. on 8/22/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FirebaseUploadImage : NSObject
+ (void)upload: (NSArray<UIImage *> * _Nonnull)images withPath: (NSString *_Nonnull)path completeHandler:(void(^)(NSArray<NSURL *> *urls, NSError *_Nullable error)) handler;
@end

NS_ASSUME_NONNULL_END
