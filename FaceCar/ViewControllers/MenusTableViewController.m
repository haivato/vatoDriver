//
//  MenusTableViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/1/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "MenusTableViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "KYDrawerController.h"
#import "HomeViewController.h"
#import "FacecarNavigationViewController.h"
#import "CustomMenuHeader.h"
#import "FCCreateCarViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCWebViewController.h"
#import "UIView+Border.h"
#import "CarManagementViewController.h"
#import "TripManagerViewController.h"
#import "InviteFriendTableViewController.h"
#import "TripDayViewController.h"
#import "FCNotifyViewController.h"
#import "UIView+Border.h"
#import "ProfileViewController.h"
#import "InviteViewController.h"
#import "FCHelpViewController.h"
#import "ProfileDetailViewController.h"
#import "FavoriteViewController.h"
#import "FCNewWebViewController.h"
#import "FCVatoPayViewController.h"

#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

typedef enum : NSUInteger {
    Gara,
    Deposit,
//    FavPlace,
    Trip,
    Notify,
    BlackList,
    Invite,
    RoyalPoints
} Menu;

@interface MenusTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblCarCode;
@property (weak, nonatomic) IBOutlet UIView *lbCodeView;
@property (weak, nonatomic) IBOutlet UILabel *lblUnreadNotify;
@property (weak, nonatomic) IBOutlet UILabel *lblUnreadQuickSupport;
@property (strong, nonatomic) FCSetting* setting;
@property (strong, nonatomic) ReferralObjcWrapper *referral;
@property (strong, nonatomic) QuickSupportObjcWrapper *quickSupport;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;

@end

@implementation MenusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    self.referral = [[ReferralObjcWrapper alloc] initWith:self];
    self.quickSupport = [[QuickSupportObjcWrapper alloc] initWith:self];
    [self.lblUnreadNotify circleView:[UIColor clearColor]];
    self.lblUnreadNotify.hidden = YES;
    
    [self.lblUnreadQuickSupport circleView:[UIColor clearColor]];
    self.lblUnreadQuickSupport.hidden = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    // init icon profile
    [RACObserve([FirebaseHelper shareInstance], appSettings) subscribeNext:^(id x) {
        @strongify(self);
        if (x) {
            self.setting = x;
            [self.tableView reloadData];
        }
    }];
    self.navigationController.navigationBar.hidden = YES;
    [self.lbCodeView borderViewWithColor:[UIColor orangeColor] andBorderWidth:1.0f andRadius:3.0f];
    
    KYDrawerController *elDrawer = (KYDrawerController*)self.navigationController.parentViewController;
    elDrawer.screenEdgePanGestreEnabled = NO;
    
    [self.tableView setScrollEnabled:[self isIpad]];
    [self.tableView setScrollEnabled:YES];
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    self.tableView.contentInset = UIEdgeInsetsMake(-rect.size.height, 0, 0, 0);
    self.tableView.backgroundColor = [UIColor colorWithRed:247/255.f green:247/255.f blue:247/255.f alpha:1.f];
    
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectZero];
    viewBg.backgroundColor = UIColor.clearColor;
    UIView *topBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height/2)];
    topBG.backgroundColor = GREEN_COLOR;
    [viewBg addSubview:topBG];
    self.tableView.backgroundView = viewBg;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setStatusBarBackground: UIColorFromRGB(0x666666)];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self setStatusBarBackground:[UIColor clearColor]];
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void) setStatusBarBackground: (UIColor*) color {
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//
//    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
////        statusBar.backgroundColor = UIColorFromRGB(0x404040);
//           statusBar.backgroundColor = color;
//    }
}
- (void) bindingData {
    [RACObserve(self.homeViewModel, driver) subscribeNext:^(FCDriver* x) {
        if (x) {
            [self.tableView reloadData];
        }
        
        
        if (x && x.vehicle) {
            [self.lblCarCode setText:[NSString stringWithFormat:@" %@ ", x.vehicle.plate]];
        }
        else {
            [self.lblCarCode setText:@"Chưa có xe"];
        }
    }];
    
    [RACObserve(self.homeViewModel, totalUnreadNotify) subscribeNext:^(id x) {
        if (x && [x isKindOfClass:[NSNumber class]]) {
            NSInteger unread = [x integerValue];
            [self.lblUnreadNotify setHidden:unread <= 0];
            [self.lblUnreadNotify setText: unread > 9 ? @"9+" : [NSString stringWithFormat:@"%ld", (long)unread]];
        }
    }];
}

- (void)showProfile
{
    UIViewController * vc = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileDetailViewController"];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    [navController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:navController animated:TRUE completion:nil];
}

- (void) loadPageId: (FCLinkConfigure*) link {
    FCNewWebViewController* vc = [[FCNewWebViewController alloc] init];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:vc
                       animated:YES
                     completion:^{
                         [vc loadWebviewWithConfigure:link];
                     }];
}

- (void) loadSummaryBonus: (FCLinkConfigure*) link {
    FCNewWebViewController* vc = [[FCNewWebViewController alloc] init];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:vc
                       animated:YES
                     completion:^{
                         [vc loadWebviewWithConfigure:link];
                     }];
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.setting.isApply && (indexPath.row == Trip || indexPath.row == Deposit)) {
        return 0;
    }
    else
        return 55;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSArray* links = [FirebaseHelper shareInstance].appConfigure.app_link_configure;
    for (FCLinkConfigure* link in links) {
        if (link.active && link.type == LinkConfigureTypeSummaryBonusPage) {
            return 190;
        }
    }
    return 150;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        
        CustomMenuHeader *headerView = [[UINib nibWithNibName:@"CustomMenuHeader" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        
        headerView.homViewModel = self.homeViewModel;
        [headerView setProfileClickCallback:^{
            [self showProfile];
        }];
        
        [headerView setPageIDClickCallback:^(FCLinkConfigure * url) {
            if (url) {
                [self loadPageId: url];
            }
        }];
        
        [headerView setPageSummaryBonusClickCallback:^(FCLinkConfigure * url) {
            if (url) {
                [self loadSummaryBonus: url];
            }
        }];
         
        return headerView;
    }
    return nil;
}

- (NSString*) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        
        UIViewController *vc;
        DLog(@"Row: %ld", (long)indexPath.row);
        switch (indexPath.row) {
            case Gara:
                vc = [[CarManagementViewController alloc] initViewWithHomeViewModel:self.homeViewModel];
                
                break;
            case Trip:
                vc = [[TripDayViewController alloc] initViewController];
                
                break;
            
            case Deposit:
                vc = [[FCVatoPayViewController alloc] init];
                break;
                
            case Invite:
                if (_referral) {
                    [_referral present];
                }
                break;
                
            case BlackList:
                vc = [[FavoriteViewController alloc] initView:self.homeViewModel];
                break;
                
            case Notify:
                vc = [[FCNotifyViewController alloc] initView];
                ((FCNotifyViewController*)vc).homeViewModel = self.homeViewModel;
                break;
                
//            case Blog:
//                vc = [[FCWebViewController alloc] initViewWithViewModel:[[FCWebViewModel alloc] initWithUrl:BLOG_URL]];
                break;
                
            case RoyalPoints: {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CreditPoint" bundle:nil];
                vc = [storyboard instantiateViewControllerWithIdentifier:@"CreditPointsVC"];
            }
                break;
//            case FavPlace:
//            {
//                vc = [[FavoritePlaceViewController alloc] init];
//                __weak typeof(self) selfWeak = self;
//                [(FavoritePlaceViewController*)vc setDidSelectModel:^(ActiveFavoriteModeModel *model) {
//                    if (selfWeak.didSelecFavMode) {
//                        selfWeak.didSelecFavMode(model);
//                    }
//                }];
//            }
//                break;
            default:
                break;
        }
    
        if (vc) {
            FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
            [navController setModalPresentationStyle: UIModalPresentationFullScreen];
            [self presentViewController:navController animated:TRUE completion:nil];
        }
    }
    
}

- (void) showHome {
    KYDrawerController *elDrawer = (KYDrawerController*)self.navigationController.parentViewController;
    [elDrawer setDrawerState:KYDrawerControllerDrawerStateClosed animated:YES];
}

@end
