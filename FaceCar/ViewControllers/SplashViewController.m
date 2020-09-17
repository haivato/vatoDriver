//
//  SplashViewController.m
//  FaceCar
//
//  Created by facecar on 4/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "SplashViewController.h"
#import "FacecarNavigationViewController.h"
#import "AppDelegate.h"
#import "UserDataHelper.h"
#import "FCApplyLoginViewController.h"

#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

@interface SplashViewController ()

@property (weak, nonatomic) IBOutlet FCProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *topBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBgImageView;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTheme];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.progressView show];
    FIRUser* user = [[FIRAuth auth] currentUser];
    if (user) {
        if ([self isNetworkAvailable]) {
            [user getIDTokenForcingRefresh:YES
                                completion:^(NSString* token, NSError* error) {
                                    if (error && error.code != FIRAuthErrorCodeNetworkError) {
                                        NSError* err;
                                        [[UserDataHelper shareInstance] clearUserData];
                                        [[FIRAuth auth] signOut:&err];
                                    }
                                    
                                    [self checkUserAuthen];
                                }];
        }
        else {
            [self checkUserAuthen];
        }
    }
    else {
        // make sure info clear
        [[UserDataHelper shareInstance] clearUserData];
        [self checkUserAuthen];
    }
}

- (void) loadLoginView {
    UIViewController* vc = [[UIStoryboard storyboardWithName:STORYBOARD_LOGIN bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self presentViewController:vc animated:YES completion:^{
        __weak AppDelegate * const appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        [appDelegate checkUpdateVersion];
    }];
}

- (void) loadLoginForApplyView {
    FCApplyLoginViewController* vc = [[FCApplyLoginViewController alloc] initView];
    [self presentViewController:vc animated:NO completion:^{

    }];
}


- (void) loadHomeView {
    UIViewController *viewController = [[NavigatorHelper shareInstance] getViewControllerById:MAIN_VIEW_CONTROLLER
                                                                                 inStoryboard:STORYBOARD_MAIN];
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self presentViewController:viewController animated:YES completion:^{
        __weak AppDelegate * const appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        [appDelegate checkUpdateVersion];
    }];
}

#pragma mark - Check Settings

- (IBAction)outClicked:(id)sender {
    [[FIRAuth auth] signOut:nil];
}

- (void) checkUserAuthen {
    [[FirebaseHelper shareInstance] getDriver:^(FCDriver * driver) {
        if (driver) {
            [self loadHomeView];
        }
        else {
            [self loadLoginView];
        }
    }];
}

- (void)_handleNotification:(NSNotification *)notification {
    __weak AppDelegate * const appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [appDelegate checkUpdateVersion];
}

- (void)loadTheme {
    [[ThemeManager instance] setPDFImageWithName:@"bg_splash_driver_top" view:self.topBgImageView placeholder: nil];
    [[ThemeManager instance] setPDFImageWithName:@"bg_splash_driver_bottom" view:self.bottomBgImageView placeholder: nil];
}


@end
