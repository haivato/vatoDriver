//
//  FCPhotoPickerViewController.h
//  FaceCar
//
//  Created by facecar on 5/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSKImageCropViewController.h"

@interface FCPhotoPicker : UIViewController <RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIImage* imageRes;
@property (assign, nonatomic) RSKImageCropMode imageMode;

- (instancetype) initWithType: (RSKImageCropMode) type;

@end
