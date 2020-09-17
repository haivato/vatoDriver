//
//  FCNotificationDetailViewController.m
//  FC
//
//  Created by tony on 11/19/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import "FCNotificationDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface FCNotificationDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UITextView *textviewDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consImageViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@end

@implementation FCNotificationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    self.btnClose.hidden = YES;
    
    if (self.notification.type == NotifyTypeManifest) {
        [self getManifestDetail: self.notification.extra];
    }
    else {
        [self loadDetailInfo:self.notification];
    }
}

- (void) getManifestDetail: (NSString*) extra {
    [IndicatorUtils show];
    NSDictionary* param = @{@"id": extra};
    [[APIHelper shareInstance] get:API_GET_MANIFEST_DETAIL params:param complete:^(FCResponse *response, NSError *e) {
        [IndicatorUtils dissmiss];
        if (response.status == APIStatusOK) {
            FCManifest* manifest = [[FCManifest alloc] initWithDictionary:response.data error:nil];
            if (manifest) {
                FCNotification* notify = [[FCNotification alloc] init];
                notify.title = manifest.title;
                notify.body = manifest.description;
                notify.createdAt = manifest.createdAt;
                notify.bannerUrl = manifest.banner;
                self.notification = notify;
            }
            [self loadDetailInfo:self.notification];
        }
        else {
            [self loadDetailInfo:self.notification];
        }
    }];
}

- (IBAction) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) loadDetailInfo: (FCNotification*) notification {
    self.lblTitle.text = notification.title;
    self.textviewDescription.text = notification.body;
    [self.lblTime setText:[self getTimeString:notification.createdAt]];
    if (notification.bannerUrl.length > 0) {
        self.consImageViewHeight.constant = 210;
        self.imageViewBanner.hidden = NO;
        self.btnClose.hidden = NO;
        NSString* banner = [notification.bannerUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [self.imageViewBanner setImageWithURL:[NSURL URLWithString:banner] placeholderImage:nil];
    }
    else {
        self.consImageViewHeight.constant = 0;
        self.imageViewBanner.hidden = YES;
        self.navigationController.navigationBarHidden = NO;
    }
}

@end
