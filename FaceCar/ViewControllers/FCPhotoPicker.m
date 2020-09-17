//
//  FCPhotoPickerViewController.m
//  FaceCar
//
//  Created by facecar on 5/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPhotoPicker.h"
#import "UIImage+Helper.h"

@interface FCPhotoPicker ()

@end

@implementation FCPhotoPicker

- (instancetype) initWithType: (RSKImageCropMode) type {
    self = [super init];
    self.imageMode = type;
    
//    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
//    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    
    [self showPickerOption];
}

- (void) showPickerOption {
    [UIAlertController showActionSheetInViewController:self
                                             withTitle:nil
                                               message:nil
                                     cancelButtonTitle:@"Huỷ"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@[@"Chụp hình", @"Thư viện ảnh"]
                    popoverPresentationControllerBlock:^(UIPopoverPresentationController * _Nonnull popover) {
                    }
                                              tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                  if (buttonIndex == 2) {
                                                      // camera
                                                      [self loadPickerWithtype:UIImagePickerControllerSourceTypeCamera];
                                                  }
                                                  else if (buttonIndex == 3) {
                                                      // picker poto
                                                      [self loadPickerWithtype:UIImagePickerControllerSourceTypePhotoLibrary];
                                                  }
                                                  else {
                                                      [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                                                  }
                                                  
                                              }];
    
}

- (void) loadPickerWithtype: (UIImagePickerControllerSourceType) type {
    if(type == UIImagePickerControllerSourceTypeCamera && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        return;
    }
    if(type == UIImagePickerControllerSourceTypePhotoLibrary && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        return;
    }
    
    UIImagePickerController* pickerViewController = [[UIImagePickerController alloc] init];
    pickerViewController.delegate = self;
    pickerViewController.sourceType = type;
    [self presentViewController:pickerViewController animated:YES completion:nil];
}

#pragma mark - Image Picker Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera || picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIImageWriteToSavedPhotosAlbum(pickedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];    
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (image) {
        RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:self.imageMode];
        imageCropVC.delegate = self;
        imageCropVC.dataSource = self;
        [self.navigationController pushViewController:imageCropVC animated:YES];
    }
}


#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    NSInteger w = [UIScreen mainScreen].bounds.size.width;
    NSInteger h = croppedImage.size.height * w / croppedImage.size.width;
    self.imageRes = [croppedImage imageResizeTo:CGSizeMake(w, h)];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (CGRect) imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller {
    NSInteger w = self.view.bounds.size.width;
    NSInteger h = self.view.bounds.size.height;
    return CGRectMake(10, (h-w*9/16)/2, w-20, w*9/16);
}

- (UIBezierPath*) imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller
{
    CGRect rect = controller.maskRect;
    CGPoint point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint point2 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGPoint point3 = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint point4 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:point3];
    [triangle addLineToPoint:point1];
    [triangle addLineToPoint:point2];
    [triangle addLineToPoint:point4];
    [triangle closePath];
    
    return triangle;
}

@end
