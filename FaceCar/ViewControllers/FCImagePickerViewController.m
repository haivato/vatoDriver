//
//  FCImagePickerViewController.m
//  FC
//
//  Created by facecar on 5/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCImagePickerViewController.h"
#import "UIAlertController+Blocks.h"
#import "UIImage+ImagePickerCrop.h"

@interface FCImagePickerViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIImage* imageResult;
@end

@implementation FCImagePickerViewController

- (instancetype) initView {
    
    self = [self initWithNibName:@"FCImagePickerViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Chọn" style:UIBarButtonItemStylePlain target:self action:@selector(choosedImage:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.imageResult) {
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {

        [UIAlertController showActionSheetInViewController:self
                                                 withTitle:nil
                                                   message:nil
                                         cancelButtonTitle:@"Huỷ"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@[@"Chụp hình", @"Chọn hình từ bộ sưu tập"]
                        popoverPresentationControllerBlock:^(UIPopoverPresentationController * _Nonnull popover) {
                        }
                                                  tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                      if (buttonIndex == 2) {
                                                          [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
                                                      }
                                                      else if (buttonIndex == 1) {
                                                          [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                                      }
                                                  }];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void) backPressed: (id) sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void) choosedImage : (id) sender {
    self.viewModel = [[FCImagePickerViewModel alloc] initViewModelWithImage:self.imageResult];
    
    [IndicatorUtils showWithAllowDismiss:YES];
    [RACObserve(self.viewModel, urlImageUpload) subscribeNext:^(NSURL* url) {
        if (url) {
            [IndicatorUtils dissmiss];
            self.imageResultUrl = url;
            [self backPressed:nil];
        }
    }];
}

- (void)displayImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.allowsEditing = YES;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark - Image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imageView.image = self.imageResult = [UIImage croppedImageWithImagePickerInfo:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
