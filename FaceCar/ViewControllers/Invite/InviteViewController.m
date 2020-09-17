//
//  InviteViewController.m
//  FaceCar
//
//  Created by facecar on 3/28/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "InviteViewController.h"
#import "FCWarningNofifycationView.h"
#import "FCWebViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCFindView.h"
#import "APICall.h"
#import "FCNotifyBannerView.h"

@interface InviteViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblCode;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBody;
@property (weak, nonatomic) IBOutlet UIButton *btnMoreInfo;
@property (weak, nonatomic) IBOutlet FCButton *btnShare;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consBtnHeightShare;

@end

@implementation InviteViewController {
    FCMInvite* _invite;
    FCFindView* _findPhoneView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    [self getInviteContent];
}

- (void) btnLeftClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

- (void) setupView {
    [self setTitle:@"Giới thiệu bạn bè"];
//    self.btnShare.hidden = _homeviewModel.driver.friendCode > 0;
//    self.consBtnHeightShare.constant =  _homeviewModel.driver.friendCode > 0 ? 0 : self.consBtnHeightShare.constant;
}

- (void) reloadData {
    _lblTitle.text = _invite.title;
    _lblBody.text = _invite.body;
    [_imageView setImageWithURL:[NSURL URLWithString:_invite.icon_ref]];
    _lblCode.text = _homeviewModel.driver.user.phone;
    [_btnMoreInfo setHidden:_invite.href.length == 0];
}

- (void) showErrorNotify {
    FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] init];
    view.bgColor = [UIColor whiteColor];
    view.messColor = [UIColor darkGrayColor];
    [view show:self.view
         image:[UIImage imageNamed:@"notify-1"]
         title:@"Thông báo"
       message:@"Hiện tại chưa có chương trình giới thiệu nào, hãy thường xuyên cập nhật để nhận thông báo về các chương trình giới thiệu mới. VATO xin cảm ơn!"
      buttonOK:@"OK"
  buttonCancel:nil
      callback:^(NSInteger buttonIndex) {
          [self.navigationController dismissViewControllerAnimated:TRUE
                                                        completion:nil];
      }];
    [self.navigationController.view addSubview:view];
}

- (void) getInviteContent {
    [[FirebaseHelper shareInstance] getInviteContent:^(FCMInvite * invite) {
        if (invite && invite.enable) {
            _invite = invite;
            [self reloadData];
        }
        else {
            [self showErrorNotify];
        }
    }];
}

- (void)apiVerifyCode: (NSString*) code {
    [IndicatorUtils show];
    [[APICall shareInstance] apiVerifyRefferalCode:code withComplete:^(NSString * res, BOOL success) {
        
        [IndicatorUtils dissmiss];
        
        if (success) {
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeSuccess
                                     autoHide:YES
                                      message:@"Chúc mừng bạn nhập mã thành công"
                                   closeClick:nil
                                  bannerClick:nil];
        }
        
        [_findPhoneView removeView];
    }];
}

- (IBAction)shareCodeClicked:(id)sender {
    NSString *title = [NSString stringWithFormat:@"%@ %@ \n%@",_homeviewModel.driver.user.fullName, _invite.message, _invite.campaign_url];
    NSArray* dataToShare = @[title];
    
    UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

- (IBAction)enterInviteCode:(id)sender {
    _findPhoneView = [[FCFindView alloc] initView:self];
    [_findPhoneView setupView];
    [_findPhoneView.lblTitle setText:@"Nhập mã giới thiệu"];
    [_findPhoneView.lblError setText:@"Mã giới thiệu không hợp lệ."];
    [self.navigationController.view addSubview:_findPhoneView];
    
    [RACObserve(_findPhoneView, phoneNumber) subscribeNext:^(NSString* phone) {
        if (phone) {
            if ([phone isEqualToString:_homeviewModel.driver.user.phone]) {
                _findPhoneView.lblError.text = @"Rất tiếc, bạn không thể nhập mã của chính mình.";
                _findPhoneView.lblError.hidden = NO;
            }
            else {
                [self apiVerifyCode:phone];
            }
        }
    }];
}

- (IBAction)moreInfoClicked:(id)sender {
    FCWebViewController* vc = [[FCWebViewController alloc] initViewWithViewModel:[[FCWebViewModel alloc] initWithUrl:_invite.href]];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

@end
