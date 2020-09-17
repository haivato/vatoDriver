//
//  FCUploadImageProcessViewController.m
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCUploadImageProcessViewController.h"
#import "FCPhotoPicker.h"
#import "FacecarNavigationViewController.h"

@interface FCUploadImageProcessViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@end

@implementation FCUploadImageProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.imageType == FONT_CMND) {
        self.lblTitle.text = @"Mặt trước CMND / Hộ Chiếu";
    }
    else if (self.imageType == BACK_CMND) {
        self.lblTitle.text = @"Mặt sau CMND / Hộ Chiếu";
    }
    else if (self.imageType == AVATAR) {
        self.lblTitle.text = @"Hình đại diện";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)imageAddTouch:(id)sender {
    RSKImageCropMode type = self.imageType == AVATAR ? RSKImageCropModeCircle : RSKImageCropModeCustom;
    FCPhotoPicker* vc = [[FCPhotoPicker alloc] initWithType:type];
    FacecarNavigationViewController* nav = [[FacecarNavigationViewController alloc] initWithRootViewController:vc];
    
    nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:nav animated:NO completion:nil];
    
    [RACObserve(vc, imageRes) subscribeNext:^(UIImage* image) {
        if (image) {
            [IndicatorUtils show];
            
            NSString* path;
            if (self.imageType == AVATAR) {
                path = [NSString stringWithFormat:@"profile/%@/Avatar_%ld.png", [FIRAuth auth].currentUser.uid, (long)[self getCurrentTimeStamp]];
            }
            else if (self.imageType == FONT_CMND) {
                path = [NSString stringWithFormat:@"profile/%@/CardImgFront_%ld.png", [FIRAuth auth].currentUser.uid, (long)[self getCurrentTimeStamp]];
            }
            else {
                path = [NSString stringWithFormat:@"profile/%@/CardImgBack_%ld.png", [FIRAuth auth].currentUser.uid, (long)[self getCurrentTimeStamp]];
            }
            
            [[FirebaseHelper shareInstance] uploadImage:image withPath: path handler:^(NSURL * _Nullable url) {
                [IndicatorUtils dissmiss];
                
                DLog(@"[Upload image] : %@",url.absoluteString);
                if (url) {
                    self.imageUrlResult = url.absoluteString;
                    [self backPressed:nil];
                }
            }];
        }
    }];
}

@end
