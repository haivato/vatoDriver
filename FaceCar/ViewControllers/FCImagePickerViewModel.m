//
//  FCImagePickerViewModel.m
//  FC
//
//  Created by facecar on 5/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCImagePickerViewModel.h"

@implementation FCImagePickerViewModel

- (instancetype) initViewModelWithImage:(UIImage *)image {
    self = [super init];
    
    [self uploadImageToServer:image];
    
    return self;
}

- (void) uploadImageToServer: (UIImage*) image {
    [[FirebaseHelper shareInstance] uploadImage:image handler:^(NSURL* url) {
        self.urlImageUpload = url;
    }];
}

@end
