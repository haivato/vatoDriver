//
//  FCImagePickerViewModel.h
//  FC
//
//  Created by facecar on 5/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCImagePickerViewModel : NSObject

- (instancetype) initViewModelWithImage: (UIImage*) image;

@property (strong,  nonatomic) NSURL* urlImageUpload;

@end
