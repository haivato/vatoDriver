//
//  ProfileViewController.m
//  FC
//
//  Created by facecar on 10/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "ProfileViewController.h"
#import "FCWebViewController.h"
#import "FacecarNavigationViewController.h"
#import "UIView+Border.h"
#import "UIImageView+AFNetworking.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

typedef enum : NSUInteger {
    About,
    Help,
    PriceCal
} Menu;

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.imgAvatar circleView:[UIColor clearColor]];
    
    [self.imgAvatar setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.homeViewmodel.driver.user.avatarUrl]] placeholderImage:[UIImage imageNamed:@"avatar-placeholder"] success:nil failure:nil];
    [self.lblPhone setText:self.homeViewmodel.driver.user.phone];
    [self.lblName setText:self.homeViewmodel.driver.user.fullName];
}

- (IBAction)backPressed:(id)sender {
        if (self.presentingViewController.presentedViewController == self ||
            ((self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController) ||
             [self.tabBarController.presentingViewController isKindOfClass: [UITabBarController class]])){
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        else {
            [self.navigationController popViewControllerAnimated:TRUE];
        }
}

- (void) logout {
    [[FirebaseHelper shareInstance] signOut:^(NSError *error) {
        if (!error) {
            [[TOManageCommunication shared] stop];
            [[TOManageCommunication shared] cleanUp];
            [[VatoPermission shared] cleanUp];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LogOutEvent" object:nil];
            UIViewController* startview = [[NavigatorHelper shareInstance] getViewControllerById:LOGIN_VIEW_CONTROLLER
                                                                                    inStoryboard:STORYBOARD_LOGIN];
            startview.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [startview setModalPresentationStyle:UIModalPresentationFullScreen];
            [self.navigationController presentViewController:startview
                                                    animated:YES
                                                  completion:nil];
        }
    }];
}


#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return 50;
}

- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    /*
    if (self.homeViewmodel.driver.approveStatus == APPROVED ||
        self.homeViewmodel.driver.verification >= LVL_CARD) {
        return nil;
    }
    
    if (section == 0) {
        UIView* bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 30, 30)];
        lbl.font = [UIFont systemFontOfSize:12];
        lbl.textColor = [UIColor redColor];
        lbl.numberOfLines = 0;
        if (self.homeViewmodel.driver.approveStatus == WAIT_FOR_APPROVAL) {
            self.cellRegisterProfileLvl2.userInteractionEnabled = NO;
            lbl.text = @"Tài khoản đang chờ duyệt";
        }
        else if (self.homeViewmodel.driver.approveStatus == CANCELED ||
                 self.homeViewmodel.driver.approveStatus == REJECTED) {
            if (self.homeViewmodel.driver.approveDesc.length > 0)
                lbl.text = self.homeViewmodel.driver.approveDesc;
            else
                lbl.text = @"Tài khoản bị từ chối xét duyệt. Cập nhật lại ngay!";
        }
        else {
            lbl.text = @"Nâng cấp tài khoản để thực hiện các giao dịch rút và chuyển tiền.";
            lbl.textColor = [UIColor grayColor];
        }
        [bg addSubview:lbl];
        return bg;
    }
     */
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        
        UIViewController *vc;
        DLog(@"Row: %ld", (long)indexPath.row);
        switch (indexPath.row) {
           
            case About:
                vc = [[FCWebViewController alloc] initViewWithViewModel:[[FCWebViewModel alloc] initWithUrl:VATO_URL]];
                
                break;
            case Help:
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://profile/769582413142908"]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/769582413142908"]];
                }
                else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/groups/769582413142908"]];
                }
                break;
            case PriceCal:
                vc = [[UIStoryboard storyboardWithName:@"PriceCalculate"
                                                bundle:nil] instantiateViewControllerWithIdentifier:@"TripPaymentViewController"];
                break;
            default:
                break;
        }
        
        if (vc) {
            FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
            [self presentViewController:navController animated:TRUE completion:nil];
        }
    }
    else if (indexPath.section == 2) {
        
        [UIAlertController showAlertInViewController:self
                                           withTitle:@"Thoát ứng dụng"
                                             message:@"Bạn thực sự muốn thoát khỏi ứng dụng?"
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:@"Huỷ bỏ"
                                   otherButtonTitles:@[@"Đồng ý"]
                                            tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                       if (buttonIndex == 2) {
                                           [self logout];
                                       }
                                   }];
    }
    
}

@end
