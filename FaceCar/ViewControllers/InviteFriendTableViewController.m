//
//  InviteFriendTableViewController.m
//  FaceCar
//
//  Created by facecar on 4/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "InviteFriendTableViewController.h"
#import "APICall.h"
#import "UserDataHelper.h"
#import "UIView+Border.h"
#import "FirebaseDynamicLinkHelper.h"
#import "FCWarningNofifycationView.h"

@interface InviteFriendTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgQRcode;
@property (weak, nonatomic) IBOutlet UILabel *lblQRCode;
@property (weak, nonatomic) IBOutlet UILabel *lblCodeCount;
@property (weak, nonatomic) IBOutlet UITextField *tfEnterCode;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIView *myShareView;
@property (weak, nonatomic) IBOutlet UIView *friendShareView;
@property (weak, nonatomic) IBOutlet UIView *enterCodeView;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmCodeTitle;


@property (strong, nonatomic) FCDriver* driver;


@end

@implementation InviteFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] intView];
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
    
    self.tfEnterCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.tfEnterCode.delegate = self;
    
    [self.myShareView borderViewWithColor:[UIColor clearColor] andRadius:5];
    [self.lblCodeCount borderViewWithColor:[UIColor clearColor] andRadius:15];
    [self.enterCodeView borderViewWithColor:[UIColor grayColor] andRadius:5];
    [self.friendShareView borderViewWithColor:[UIColor clearColor] andRadius:5];
    
    [RACObserve(self.homeViewModel, driver) subscribeNext:^(FCDriver* x) {
        if (x) {
            self.driver = x;
            if (self.driver.code.length == 0) {
                [IndicatorUtils show];
                [[APICall shareInstance] apiGetRefferalCodeWithComplete:^(NSString * code) {
                    [IndicatorUtils dissmiss];
                    if (code.length > 0) {
                        [self.lblQRCode setText:code];
                    }
                }];
            }
            else {
                [self.lblQRCode setText:self.driver.code];
            }
        }
    }];

    [RACObserve(self.lblQRCode, text) subscribeNext:^(NSString* x) {
        if (x.length > 0) {
            [self genaratorQRCode];
        }
    }];
    
    // verify code
    if (self.inviteCode.length > 0) {
        [self verifyCode:self.inviteCode];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) share: (NSString*) code {
    [IndicatorUtils show];
    [[FirebaseDynamicLinkHelper shareInstance] buildFDLLink:code complete:^(NSURL *link) {
        [IndicatorUtils dissmiss];
        NSString* url = [link absoluteURL];
        NSString *title = [NSString stringWithFormat:@"Cài đặt VATO %@ \nVà nhập mã: %@",url, code];
        NSArray* dataToShare = @[title];
        
        UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
        [self presentViewController:activityViewController animated:YES completion:^{}];
    }];
    
}

- (IBAction)menuClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:TRUE completion:nil];
}

- (IBAction)helpClicked:(id)sender {
    if ([FirebaseHelper shareInstance].appConfigs.notification.active) {
        [UIAlertController showAlertInViewController:self
                                           withTitle:@"Hướng dẫn"
                                             message:[FirebaseHelper shareInstance].appConfigs.notification.message
                                   cancelButtonTitle:@"Đóng"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                
                                            }];
    }
}

- (IBAction)shareCodeClicked:(id)sender {
    if (self.lblQRCode.text.length == 0) {
        return;
    }
    
    [self share:self.lblQRCode.text];
    
}

- (IBAction)shareFriendCodeClicked:(id)sender {
    if (self.tfEnterCode.text.length == 0) {
        return;
    }
    
    if (self.tfEnterCode.enabled) {
        [self verifyCode: self.tfEnterCode.text];
        return;
    }
    
    [self share:self.tfEnterCode.text];
}

- (void) verifyCode : (NSString*) code {
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Xác thực mã bạn bè"
                                         message:[NSString stringWithFormat:@"Bạn có chắc chắn nhập mã '%@'", code]
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"Không"
                               otherButtonTitles:@[@"Đồng ý"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if (buttonIndex == 2) {
                                                [self apiVerifyCode:code];
                                            }
                                        }];
    
}

- (void) apiVerifyCode : (NSString*) code {
    [IndicatorUtils show];
    [[APICall shareInstance] apiVerifyRefferalCode:code withComplete:^(NSString * res, BOOL success) {
        
        [IndicatorUtils dissmiss];
        
        if (success) {
            [self showMessageBanner:@"Chúc mừng bạn nhập mã thành công"
                             status:YES];
        }
    }];
}

- (IBAction)scanQRCodeClicked:(id)sender {
}

- (void) genaratorQRCode {
    CGRect rect = self.imgQRcode.frame;
    rect.origin.x = ([[UIScreen mainScreen] bounds].size.width - rect.size.width)/2;

    UIImageView *myImage = [[UIImageView alloc] initWithImage:nil];
    [self.view addSubview:myImage];
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    
    if (lowercaseCharRange.location != NSNotFound) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString:[string uppercaseString]];
        return NO;
    }
    
    return YES;
}

@end
