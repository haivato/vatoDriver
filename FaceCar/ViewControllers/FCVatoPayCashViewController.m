//
//  FCVatoPayCashViewController.m
//  FC
//
//  Created by tony on 12/11/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import "FCVatoPayCashViewController.h"
#import "FCInvoiceManagerViewController.h"
#import "FCWithdrawViewController.h"
#import "FCPasscodeViewController.h"
#import "FCInvoiceDetailViewController.h"

#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

@interface FCVatoPayCashViewController ()<WalletListHistoryDetailProtocol>
@property (weak, nonatomic) IBOutlet UILabel *lblTotalAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblAvailableAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblPenddingAmount;


// withdraw
@property (weak, nonatomic) IBOutlet UILabel *lblWithdraw;
@property (weak, nonatomic) IBOutlet UIView *withdrawView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consWithdrawHeight;

// tranfer
@property (weak, nonatomic) IBOutlet UILabel *lblTransferMoney;
@property (weak, nonatomic) IBOutlet UIView *transferMoneyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consTransferMoneyHeight;

@property (strong, nonatomic) WalletListHistoryObjcWrapper *wrapper;

@end

@implementation FCVatoPayCashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Doanh thu chuyến đi";
    @weakify(self);
    [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (error) {
            return;
        }
        @strongify(self);
        self.wrapper = [[WalletListHistoryObjcWrapper alloc] initWithVC:self firebaseAuthen:token type:ListHistoryTypeHardCash];
    }];
    
    [self registerListener];
    
    [self checkWithdrawView];
    [self checkTransferMoneyView];
    
    if (self.balance) {
        [self reloadView];
    }
    else {
        [self fetchBalance];
    }
}

- (void) showDetailFrom:(NSDictionary<NSString *,id> *)json {
    FCInvoiceDetailViewController* detailVC = [[FCInvoiceDetailViewController alloc] init];
    detailVC.isPushedView = YES;
    FCInvoice *i = [[FCInvoice alloc] initWithDictionary:json error:nil];
    [detailVC setInvoice:i];
    [self.navigationController pushViewController:detailVC
                                         animated:YES];
}

- (void) registerListener {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchBalance)
                                                 name:NOTIFICATION_TRANSFER_MONEY_COMPLETED
                                               object:nil];
}

- (void) removeListener {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TRANSFER_MONEY_COMPLETED object:nil];
}

- (void) fetchBalance {
    [APICall apiGetMyBalance:^(FCBalance * balance) {
        self.balance = balance;
        [self reloadView];
    }];
}

- (void) reloadView {
    if (!self.balance) {
        return;
    }
    
    self.lblTotalAmount.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:(self.balance.hardCash + self.balance.hardCashPending) withSeperator:@","]];
    self.lblAvailableAmount.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:self.balance.hardCash withSeperator:@","]];
    self.lblPenddingAmount.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:self.balance.hardCashPending withSeperator:@","]];
}

- (void) loadCreatePINView {
    FCPasscodeViewController* passView = [[FCPasscodeViewController alloc] initWithNibName:@"FCPasscodeViewController"
                                                                                    bundle:nil];
    [self.navigationController pushViewController:passView
                                         animated:YES];
}


#pragma mark - Withdraw
- (void) checkWithdrawView {
    [IndicatorUtils show];
    [self enableWithdrawView:NO];
    [[APIHelper shareInstance] get:API_GET_WITHDRAW_CONFIG params:nil complete:^(FCResponse *response, NSError *e) {
        [IndicatorUtils dissmiss];
        if (response.data && [response.data valueForKey:@"withdraw"]) {
            BOOL canWithdraw = [[response.data valueForKey:@"withdraw"] boolValue];
            FCDriverConfig* config = [self getWithdrawConfig];
            [self enableWithdrawView:config && canWithdraw];
        }
    }];
}

- (void) enableWithdrawView: (BOOL) enable {
    if (enable) {
        FCDriverConfig* config = [self getWithdrawConfig];
        self.withdrawView.hidden = NO;
        self.consWithdrawHeight.constant = 56;
        self.lblWithdraw.text = config.name;
    }
    else {
        self.withdrawView.hidden = YES;
        self.consWithdrawHeight.constant = 0;
        self.lblWithdraw.text = EMPTY;
    }
    [self.tableView reloadData];
}

- (FCDriverConfig*) getWithdrawConfig {
    NSArray* configs = [FirebaseHelper shareInstance].appConfigure.driver_config;
    for (FCDriverConfig* c in configs) {
        if (c.type == DriverConfigTypeWithdrawMoney && c.active) {
            return c;
        }
    }
    
    return nil;
}

#pragma mark - Transfer Money View
- (void) checkTransferMoneyView {
    [self enableTranferView:NO withConfigure:nil];
    
    FCDriver* driver = [UserDataHelper shareInstance].getCurrentUser;
    if ([driver.enableTransferCash boolValue]) {
        FCDriverConfig* config = [self getTransferMoneyConfig];
        [self enableTranferView:config.active withConfigure:config];
    }
}

- (FCDriverConfig*) getTransferMoneyConfig {
    NSArray* configs = [FirebaseHelper shareInstance].appConfigure.driver_config;
    for (FCDriverConfig* c in configs) {
        if (c.type == DriverConfigTypeTranferMoney) {
            return c;
        }
    }
    
    return nil;
}

- (void) enableTranferView: (BOOL) enable withConfigure:(FCDriverConfig*) config {
    if (enable) {
        self.transferMoneyView.hidden = NO;
        self.consTransferMoneyHeight.constant = 56;
        self.lblTransferMoney.text = config.name;
    }
    else {
        self.transferMoneyView.hidden = YES;
        self.consTransferMoneyHeight.constant = 0;
        self.lblTransferMoney.text = EMPTY;
    }
    [self.tableView reloadData];
}

- (void) canTranserCash: (void (^) (BOOL can)) block {
    [IndicatorUtils show];
    [[APIHelper shareInstance] get:API_CHECK_TRANF_CASH
                            params:nil
                          complete:^(FCResponse *response, NSError *e) {
                              [IndicatorUtils dissmiss];
                              if (response.status == APIStatusOK) {
                                  BOOL c = [(NSNumber*)response.data boolValue];
                                  block(c);
                              }
                          }];
}


#pragma mark - Action Handler
- (void) backPressed: (id) sender {
    [self removeListener];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)withdrawTapped:(id)sender {
    __autoreleasing FCDriver *driver = [[UserDataHelper shareInstance] getCurrentUser];
    
    __autoreleasing WithdrawVC *controller = [[WithdrawVC alloc] initWithNibName:@"WithdrawVC" bundle:nil];
    controller.fullname = driver.user.fullName;
    controller.cash = self.balance.hardCash;
    [self.navigationController pushViewController:controller animated:true];
}

- (IBAction)historyTapped:(id)sender {
    [FCTrackingHelper trackEvent:@"Topup" value:@{@"ClickButton" : @"History"}];
//    FCInvoiceManagerViewController* vc = [[FCInvoiceManagerViewController alloc] initView];
//    [self.navigationController pushViewController:vc animated:YES];
    [_wrapper showList];
}

- (IBAction)transferMoneyClicked:(id)sender {
    [self canTranserCash:^(BOOL can) {
        if (can) {
            FCWithdrawViewController* vc = (FCWithdrawViewController*) [[NavigatorHelper shareInstance] getViewControllerById:@"FCWithdrawViewController" inStoryboard:@"WithdrawMoney"];
            vc.balance = self.balance;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Thông báo"
                                                 message:@"Bạn cần tạo mật khẩu thanh toán để sử dụng chức năng này. Tạo mật khẩu?"
                                       cancelButtonTitle:nil
                                  destructiveButtonTitle:@"Bỏ qua"
                                       otherButtonTitles:@[@"Đồng ý"]
                                                tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                    if (buttonIndex == 2) {
                                                        [self loadCreatePINView];
                                                    }
                                                }];
        }
    }];
}

#pragma mark - Tableview Delegate
- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
        view.backgroundColor = [UIColor clearColor];
        UILabel* lableTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
        lableTime.font = [UIFont systemFontOfSize:10];
        [lableTime setTextAlignment:NSTextAlignmentCenter];
        lableTime.textColor = UIColor.darkGrayColor;
        FCDriver *driver = [[UserDataHelper shareInstance] getCurrentUser];
        lableTime.text = [NSString stringWithFormat:@"%li | %@", (long)driver.user.id, APP_VERSION_STRING];
        [view addSubview:lableTime];
        return view;
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 18;
    }
    
    return 40;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
