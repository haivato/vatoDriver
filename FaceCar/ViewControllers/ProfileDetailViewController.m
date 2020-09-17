//
//  ProfileViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/1/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "ProfileDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "KYDrawerController.h"
#import "UIView+Border.h"
#import "FCPhotoPicker.h"
#import "FacecarNavigationViewController.h"
#import "FCPassCodeView.h"
#import "FCProfileLevel2ViewController.h"
#import "APIHelper.h"
#import "FBEncryptorAES.h"
#import "ZalopayUpdateViewController.h"
#import "FCPhoneInputView.h"
#import "FCPartnerViewController.h"
#import "APICall.h"
#import "FCPasscodeViewController.h"
#import "FCUpdateViewController.h"
#import "FCNewWebViewController.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
#import <SDWebImage/SDWebImage.h>

#define ERROR_CANNOT_LINK_MSG @"Xảy ra lỗi khi liên kết với tài khoản này. Bạn vui lòng thử lại với tài khoản khác"

@interface ProfileDetailViewController () < UITextFieldDelegate>
@property (strong, nonatomic) FCDriver* driver;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *lblBirthday;
@property (strong, nonatomic) FCSetting* settings;
@property (weak, nonatomic) IBOutlet UILabel *lblTitlePIN;
@property (weak, nonatomic) IBOutlet UILabel *lblUpdateProfile;
@property (strong, nonatomic) VatoVerifyPasscodeObjC *verifyObjc;

@end

@implementation ProfileDetailViewController {
    
    NSString* lastestPhone;
    UIImage* newAvatarImage;
    UIImage* newLienceImage;
    BOOL _havePIN;
    NSMutableArray* _listViewChangePIN;
    NSMutableArray* _listViewResetPIN;
    FCPassCodeView* newPassView;
    FCPassCodeView* changeCodeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.verifyObjc = [VatoVerifyPasscodeObjC new];
    
    self.navigationController.navigationBar.hidden = NO;
    
    [self.avatar circleView];
    self.phone.userInteractionEnabled = NO;
    
    self.driver = [[UserDataHelper shareInstance] getCurrentUser];
    lastestPhone = self.driver.user.phone;
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:self.driver.user.avatarUrl] placeholderImage:[UIImage imageNamed:@"ic_register_default_avatar"]];
    
    self.phone.text = self.driver.user.phone;
    self.name.text = [self.driver.user.fullName uppercaseString];
    [self showEmail];
    [self checkPIN];
    [self checkShowUpdateProfileView];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.view endEditing:TRUE];
}

- (void) showEmail {
    if (self.driver.user.email.length > 0) {
        self.email.text = self.driver.user.email;
    }
    else {
        [self.email setText:@"Cập nhật"];
        self.email.textColor = [UIColor grayColor];
        if ([FIRAuth auth].currentUser.email.length > 0) {
            [self.email setText:[FIRAuth auth].currentUser.email];
            self.email.textColor = [UIColor blackColor];
        }
        else {
            for (id <FIRUserInfo> info in [FIRAuth auth].currentUser.providerData) {
                if ([info.providerID isEqual:FIRGoogleAuthProviderID]) {
                    NSString* email = info.email;
                    if (email) {
                        [[FirebaseHelper shareInstance] updateUserEmail:email complete:nil];
                        [self.email setText:email];
                        self.email.textColor = [UIColor blackColor];
                        break;
                    }
                }
            }
        }
    }
}

- (void) checkPIN {
    [self havePIN:^(BOOL have) {
        _havePIN = have;
        if (have) {
            self.lblTitlePIN.text = @"Đổi mật khẩu thanh toán";
        }
        else {
            self.lblTitlePIN.text = @"Tạo mật khẩu thanh toán";
        }
    }];
}

- (void) logout {
    [[FirebaseHelper shareInstance] signOut:^(NSError *error) {
        if (!error) {
            [[VatoDriverUpdateLocationService shared] stopUpdate];
            [[TOManageCommunication shared] stop];
            [[TOManageCommunication shared] cleanUp];
            [[VatoPermission shared] cleanUp];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LogOutEvent" object:nil];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            [[[UIApplication sharedApplication] keyWindow].rootViewController dismissViewControllerAnimated:YES completion:^{
                UIViewController* startview = [[NavigatorHelper shareInstance] getViewControllerById:LOGIN_VIEW_CONTROLLER
                                                                                        inStoryboard:STORYBOARD_LOGIN];
                
                [UIView transitionFromView:[[UIApplication sharedApplication] keyWindow].rootViewController.view
                                    toView:startview.view
                                  duration:0.3 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionFlipFromLeft
                                completion:^(BOOL finished) {
                    [[UIApplication sharedApplication] keyWindow].rootViewController = startview;
                }];
            }];
            
        }
    }];
}

- (void) havePIN: (void (^) (BOOL can)) block {
    [IndicatorUtils show];
    [[APIHelper shareInstance] get:API_CHECK_TRANF_CASH
                            params:nil
                          complete:^(FCResponse *response, NSError *e) {
        [IndicatorUtils dissmiss];
        if (response.status == APIStatusOK) {
            BOOL c = [(NSNumber*)response.data boolValue];
            block(c);
        }
        else {
            block(NO);
        }
    }];
}

#pragma mark - Action Handler
- (IBAction)backPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

- (void) loadUpdateAvatar {
    FCPhotoPicker* vc = [[FCPhotoPicker alloc] initWithType:RSKImageCropModeCircle];
    FacecarNavigationViewController* nav = [[FacecarNavigationViewController alloc] initWithRootViewController:vc];
    
    nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:nav animated:NO completion:nil];
    @weakify(self)
    [RACObserve(vc, imageRes) subscribeNext:^(UIImage* image) {
        @strongify(self)
        if (image) {
            [IndicatorUtils show];
            
            NSString* path = [NSString stringWithFormat:@"profile/%@/Avatar_%ld.png", [FIRAuth auth].currentUser.uid, (long)[self getCurrentTimeStamp]];
            @weakify(self)
            [[FirebaseHelper shareInstance] uploadImage:image withPath: path handler:^(NSURL * _Nullable url) {
                @strongify(self)
                DLog(@"[Upload image] : %@",url.absoluteString);
                if (url != nil) {
                    @weakify(self)
                    [[APICall shareInstance] apiUpdateProfile:nil
                                                     nickname:nil
                                                     fullname:nil
                                                       avatar:url.absoluteString
                                                      handler:^(NSError *error) {
                        @strongify(self)
                        if (error != nil) {
                            [AlertVC showErrorFor:self error:error];
                        } else {
                            [self.avatar setImage:image];
                            [[FirebaseHelper shareInstance] updateAvatarUrl:url.absoluteString];
                        }
                        [IndicatorUtils dissmiss];
                    }];
                } else {
                    [IndicatorUtils dissmiss];
                }
            }];
        }
    }];
}

#pragma mark - Profile ID Page
- (void) checkShowUpdateProfileView {
    FCLinkConfigure* link  = [self getLinkUpdateProfile];
    if (link) {
        self.lblUpdateProfile.text = link.name;
    }
}

- (FCLinkConfigure*) getLinkUpdateProfile {
    NSArray* links = [FirebaseHelper shareInstance].appConfigure.app_link_configure;
    for (FCLinkConfigure* link in links) {
        if (link.type == LinkConfigureTypeUpdateProfile && link.active) {
            return link;
        }
    }
    
    return nil;
}

- (void) loadUpdateProfileView {
    FCLinkConfigure* link = [self getLinkUpdateProfile];
    if (!link) {
        return;
    }
    
    FCNewWebViewController* vc = [[FCNewWebViewController alloc] init];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:vc
                       animated:YES
                     completion:^{
        [vc loadWebviewWithConfigure:link];
    }];
}

#pragma mark - Tableview Delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    return 30;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FCLinkConfigure* profileLink = [self getLinkUpdateProfile];
    if (!profileLink) {
        if (section == 0) {
            return 4;
        }
    }
    else {
        if (section == 0) {
            return 5;
        }
    }
    
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCLinkConfigure* profileLink = [self getLinkUpdateProfile];
    if (!profileLink) {
        if (indexPath.section == 0 && indexPath.section == 3) {
            return 0;
        }
    }
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 160;
    }
    
    return 55;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self loadUpdateAvatar];
        }
        // email
        else if (indexPath.row == 2) {
            if (![self validEmail:self.email.text]) {
                FCUpdateViewController* vc = [[FCUpdateViewController alloc] init];
                vc.type = UpdateViewTypeEmail;
                [vc setModalPresentationStyle:UIModalPresentationFullScreen];
                [self presentViewController:vc
                                   animated:YES
                                 completion:nil];
                [RACObserve(vc, result) subscribeNext:^(NSString* email) {
                    if (email.length > 0) {
                        self.email.text = email;
                        self.email.textColor = [UIColor blackColor];
                    }
                }];
            }
        }
        else if (indexPath.row == 3) {
            [self loadUpdateProfileView];
        }
        else if (indexPath.row == 4) {
            FCNewWebViewController* webview = [[FCNewWebViewController alloc] init];
            [webview setModalPresentationStyle:UIModalPresentationFullScreen];
            [webview setTitle:@"Cập nhật vùng hoạt động"];
            [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
                @try {
#if DEV
                    NSString* link = [NSString stringWithFormat:@"https://id-dev.vato.vn/profile/zone?token=%@", token];
#else
                    NSString* link = [NSString stringWithFormat:@"https://id.vato.vn/profile/zone?token=%@", token];
#endif
                    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                    [cookieProperties setObject:@"x-access-token" forKey:NSHTTPCookieName];
                    [cookieProperties setObject:token forKey:NSHTTPCookieValue];
                    
                    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
                    
                    [self presentViewController:webview
                                       animated:YES
                                     completion:^{
                        [webview loadWebview:link];
                    }];
                }
                @catch (NSException* e) {
                    DLog(@"Error: %@", e)
                }
            }];
        }
    }
    else if (indexPath.section == 1) {
        if (!_havePIN) {
            [self loadCreatePINView];
        }
        else {
            [self loadChangePINView];
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


#pragma mark - Change Phone
- (BOOL) canChangePhone {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        return NO;
    }
    
    for (id<FIRUserInfo> provider in user.providerData) {
        if ([[provider providerID] isEqual:FIRPhoneAuthProviderID]) {
            return YES;
            break;
        }
    }
    
    return NO;
}

- (void) changePhone {
    FCLoginViewModel* loginViewModel = [[FCLoginViewModel alloc] init];
    loginViewModel.loginType = FCLoginTypeChangePhone;
    FCPhoneInputView* phoneView = [[FCPhoneInputView alloc] intView];
    phoneView.viewController = self.navigationController;
    phoneView.loginViewModel = loginViewModel;
    [self.navigationController.view addSubview:phoneView];
    [phoneView show];
    
    [RACObserve(loginViewModel, resultCode) subscribeNext:^(NSNumber* resultcode) {
        if (resultcode) {
            NSInteger code = [resultcode integerValue];
            if (code == FCLoginResultCodeVerifySMSCodeSuccess) {
                [[FIRAuth auth].currentUser updatePhoneNumberCredential:[loginViewModel getPhoneCredential]
                                                             completion:^(NSError* error) {
                    
                    DLog(@"updatePhoneNumber: %@", error);
                    
                    if (!error) {
                        [self apiVerifyChangePhone: loginViewModel.phoneNumber
                                         phoneView:phoneView];
                    }
                    else {
                        //                                                                     [phoneView.smsCodeView showError:error];
                    }
                }];
            }
        }
    }];
}

- (void) apiVerifyChangePhone: (NSString*) phone phoneView: (FCPhoneInputView*) phoneView {
    [[APIHelper shareInstance] post:API_CHANGE_PHONE_NUMBER
                               body:@{@"phone": phone}
                           complete:^(FCResponse *response, NSError *e) {
        if (response.status == APIStatusOK) {
            [[FirebaseHelper shareInstance] updateUserPhone:phone];
            [self showMessageBanner:@"Chúc mừng bạn đã đổi số điện thoại thành công!"
                             status:YES];
            [self.navigationController dismissViewControllerAnimated:YES
                                                          completion:nil];
        }
    }];
}

#pragma mark - Create PIN
- (void) loadCreatePINView {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCreatePinSuccess)
                                                 name:NOTIFICATION_CREATE_PIN_COMPLETED
                                               object:nil];
    
    FCPasscodeViewController* passView = [[FCPasscodeViewController alloc] initWithNibName:@"FCPasscodeViewController"
                                                                                    bundle:nil];
    [self.navigationController pushViewController:passView
                                         animated:YES];
}

- (void) onCreatePinSuccess {
    [self checkPIN];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_CREATE_PIN_COMPLETED
                                                  object:nil];
}

#pragma mark - Change PIN
- (void) loadChangePINView {
    if (!_listViewChangePIN) {
        _listViewChangePIN = [[NSMutableArray alloc] init];
    }
    else {
        [_listViewChangePIN removeAllObjects];
    }
    //    [self loadChangePINNewView];
    changeCodeView = [[FCPassCodeView alloc] initView:self];
    [changeCodeView setupView:PasscodeTypeClose];
    [self.navigationController.view addSubview:changeCodeView];
    [_listViewChangePIN addObject:changeCodeView];
    
    // confirm new pass
    [RACObserve(changeCodeView, passcode) subscribeNext:^(NSString* oldPass) {
        if (oldPass.length > 0) {
            [changeCodeView hideKeyboard];
            [self loadCreateNewPIN:oldPass];
        }
    }];
    
    [[changeCodeView.btnFogotPass rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [self loadEnterScurityCode];
            [self clearChangePINView];
        }
    }];
    
}
#pragma mark - Change PIN
- (void) loadChangePINNewView {
    @weakify(self);
    [_verifyObjc passcodeOn:self type:VatoObjCVerifyTypeChangePin forgot:^(NSString * _Nonnull phone) {
        @strongify(self);
        [self loadEnterScurityCode];
    } handler:^(NSString * _Nullable p, BOOL verified) {
        @strongify(self);
        [self onCreatePinSuccess];
    }];
}

- (void) loadCreateNewPIN: (NSString*) oldPass {
    newPassView = [[FCPassCodeView alloc] initView:self];
    [newPassView setupView:PasscodeTypeBack];
    newPassView.lblTitle.text = @"Nhập mật khẩu mới";
    [self.navigationController.view addSubview:newPassView];
    [_listViewChangePIN addObject:newPassView];
    newPassView.tag = 101;
    // confirm new pass
    [RACObserve(newPassView, passcode) subscribeNext:^(NSString* newPass) {
        if (newPass.length == 6) {
            [self loadConfirmPin:oldPass newPass:newPass];
        }
    }];
    
    [[newPassView.btnFogotPass rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [self loadEnterScurityCode];
            [self clearChangePINView];
        }
    }];
    
    [[newPassView.btnBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [_listViewChangePIN removeObject:newPassView];
            for (FCPassCodeView* view in _listViewChangePIN) {
                [view.textField becomeFirstResponder];
            }
        }
    }];
}
- (void) loadConfirmPin: (NSString*) oldPass
                newPass: (NSString*) newPass {
    FCPassCodeView* newPassViewConfirm = [[FCPassCodeView alloc] initView:self];
    if ([self isPhone6x]) {
        CGRect frameRect = newPassViewConfirm.frame;
        frameRect.size.height = newPassView.frame.size.height - 60;
        newPassViewConfirm.frame = frameRect;
    }
    newPassViewConfirm.tag = 100;
    [newPassViewConfirm setupView:PasscodeTypeBack];
    newPassViewConfirm.lblTitle.text = @"Xác nhận mật khẩu mới";
    [self.navigationController.view addSubview:newPassViewConfirm];
    [_listViewChangePIN addObject:newPassViewConfirm];
    
    // confirm new pass
    [RACObserve(newPassViewConfirm, passcode) subscribeNext:^(NSString* newPassConfirm) {
        if (newPassConfirm.length == 6 && newPass == newPassConfirm) {
            [self apiChangePasscode:oldPass
                                new:newPass
                              token:nil
                            handler:^(BOOL success) {
                if (success) {
                    [self clearChangePINView];
                }
            }];
        } else if (newPassConfirm.length == 6 && newPass != newPassConfirm) {
            [self showMessageBanner:@"Mật khẩu mới không khớp"
                             status:NO];
            [newPassViewConfirm removeFromSuperview];
            [newPassView removePasscode];
            [newPassView showKeyboard];
        }
    }];
    
    [[newPassViewConfirm.btnFogotPass rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [self loadEnterScurityCode];
            [self clearChangePINView];
        }
    }];
    
    [[newPassViewConfirm.btnBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [_listViewChangePIN removeObject:newPassViewConfirm];
            for (FCPassCodeView* view in _listViewChangePIN) {
                [view.textField becomeFirstResponder];
            }
        }
    }];
}

- (BOOL) isPhone6x {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIScreen.mainScreen.nativeBounds.size.height == 1334)  {
        return YES;
    }
    return NO;
}

- (void) clearChangePINView {
    if (_listViewChangePIN.count > 0) {
        for (UIView* view in _listViewChangePIN) {
            [view removeFromSuperview];
        }
    }
}
- (void) cleanNewPass {
    if (_listViewChangePIN.count > 0) {
        for (UIView* view in _listViewChangePIN) {
            if([view isKindOfClass:[FCPassCodeView class]]){
                if(view.tag == 100 || view.tag == 101){
                    [view removeFromSuperview];
                }
            }
        }
    }
    [changeCodeView removePasscode];
    [changeCodeView showKeyboard];
}

- (void) apiChangePasscode: (NSString*) oldPass
                       new: (NSString*) newPass
                     token: (NSString*) token
                   handler: (void (^)(BOOL success)) block {
    NSDictionary* body;
    if (oldPass.length > 0) {
        body = @{@"oldPin" : oldPass,
                 @"newPin" : newPass};
    }
    else if (token.length > 0) {
        body = @{@"resetToken" : token,
                 @"newPin" : newPass};
    }
    if (!body) {
        return;
    }
    
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_CHANGE_PIN
                               body:body
                           complete:^(FCResponse *response, NSError *e) {
        [IndicatorUtils dissmiss];
        BOOL ok = [(NSNumber*)response.data boolValue];
        if (response.status == APIStatusOK && ok) {
            [self showMessageBanner:@"Chúc mừng bạn đổi mật khẩu thanh toán thành công."
                             status:YES];
            block(TRUE);
        }
        else {
            block(NO);
            [self cleanNewPass];
        }
    }];
}

#pragma mark - Reset PIN
- (void) apiRequireResetPIN {
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_RESET_PIN
                               body:nil
                           complete:^(FCResponse *response, NSError *e) {
        [IndicatorUtils dissmiss];
        
        BOOL b = [(NSNumber*) response.data boolValue];
        if (response.status == APIStatusOK && b) {
            [self callPhone:PHONE_CENTER];
            [self showScurityCodeView];
        }
        else {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Thông báo"
                                                 message:@"Hiện tại chưa thực hiện được yêu cầu thay đổi mật khẩu của bạn. Vui lòng quay lại sau."
                                       cancelButtonTitle:@"Đồng ý"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            }];
        }
    }];
}

- (void) loadEnterScurityCode {
    __weak typeof(self) weakSelf = self;
    [AlertVC showAlertObjcOn:self
                       title:@"Thông báo"
                     message:@"Bạn cần phải nhập mã bảo mật từ hệ thống để tạo lại mật khẩu. Gọi đến tổng đài để nhận mã bảo mật ngay?"
                    actionOk:@"Gọi ngay"
                actionCancel:@"Huỷ"
                  callbackOK:^{
        [weakSelf apiRequireResetPIN];
    }
              callbackCancel:^{
    }];
}

- (void) showScurityCodeView {
    if (_listViewResetPIN) {
        [_listViewResetPIN removeAllObjects];
    }
    else {
        _listViewResetPIN = [[NSMutableArray alloc] init];
    }
    FCPassCodeView* passcodeView = [[FCPassCodeView alloc] initView:self];
    passcodeView.lblTitle.text = @"Nhập mã bảo mật từ hệ thống";
    passcodeView.lblError.text = @"Nhập mã nhân viên tổng đài cung cấp.";
    passcodeView.lblError.hidden = NO;
    passcodeView.passcodeView.length = 8;
    passcodeView.btnFogotPass.hidden = YES;
    passcodeView.lblFogotPass.hidden = YES;
    [passcodeView setupView:PasscodeTypeClose];
    [self.navigationController.view addSubview:passcodeView];
    [_listViewResetPIN addObject:passcodeView];
    
    // confirm new pass
    [RACObserve(passcodeView, passcode) subscribeNext:^(NSString* secirityCode) {
        if (secirityCode.length > 0) {
            [passcodeView hideKeyboard];
            [self loadNewPIN:secirityCode];
        }
    }];
}

- (void) loadNewPIN: (NSString*) secirityCode {
    FCPassCodeView* passcodeView = [[FCPassCodeView alloc] initView:self];
    passcodeView.lblTitle.text = @"Nhập mật khẩu mới";
    passcodeView.btnFogotPass.hidden = YES;
    passcodeView.lblFogotPass.hidden = YES;
    [passcodeView setupView:PasscodeTypeBack];
    [self.navigationController.view addSubview:passcodeView];
    [_listViewResetPIN addObject:passcodeView];
    
    // confirm new pass
    [RACObserve(passcodeView, passcode) subscribeNext:^(NSString* newPass) {
        if (newPass.length > 0) {
            [passcodeView hideKeyboard];
            [self loadReEnterNewPIN:secirityCode pin:newPass];
        }
    }];
    
    [[passcodeView.btnBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [_listViewResetPIN removeObject:passcodeView];
            for (FCPassCodeView* view in _listViewResetPIN) {
                [view.textField becomeFirstResponder];
            }
        }
    }];
}

- (void) loadReEnterNewPIN: (NSString*) secirityCode pin: (NSString*) newPin {
    FCPassCodeView* passcodeView = [[FCPassCodeView alloc] initView:self];
    passcodeView.lblTitle.text = @"Xác thực mật khẩu";
    passcodeView.btnFogotPass.hidden = YES;
    passcodeView.lblFogotPass.hidden = YES;
    [passcodeView setupView:PasscodeTypeBack];
    [self.navigationController.view addSubview:passcodeView];
    [_listViewResetPIN addObject:passcodeView];
    
    // confirm new pass
    [RACObserve(passcodeView, passcode) subscribeNext:^(NSString* newPass) {
        if (newPass.length > 0) {
            if ([newPass isEqualToString:newPin]) {
                [self apiChangePasscode:nil
                                    new:newPin
                                  token:secirityCode
                                handler:^(BOOL success) {
                    if (success) {
                        [self clearResetPINView];
                    }
                }];
                
            }
            else {
                passcodeView.lblError.text = @"Mật khẩu mới không chính xác.";
                passcodeView.lblError.hidden = NO;
            }
        }
    }];
    
    [[passcodeView.btnBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [_listViewResetPIN removeObject:passcodeView];
            for (FCPassCodeView* view in _listViewResetPIN) {
                [view.textField becomeFirstResponder];
            }
        }
    }];
}

- (void) clearResetPINView {
    if (_listViewResetPIN.count > 0) {
        for (UIView* view in _listViewResetPIN) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Partner View
- (void) loadPartnerView {
    FCPartnerViewController* partner = [[FCPartnerViewController alloc] init];
    [partner setupBackNav];
    [self.navigationController pushViewController:partner
                                         animated:YES];
}

@end
