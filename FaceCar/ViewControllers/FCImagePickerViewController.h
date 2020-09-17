//
//  FCImagePickerViewController.h
//  FC
//
//  Created by facecar on 5/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCImagePickerViewModel.h"

@interface FCImagePickerViewController : UIViewController

- (instancetype) initView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) FCImagePickerViewModel* viewModel;
@property (strong, nonatomic) NSURL* imageResultUrl;

@end
