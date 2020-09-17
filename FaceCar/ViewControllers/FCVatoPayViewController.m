//
//  VatoPayViewController.m
//  FC
//
//  Created by tony on 12/11/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import "FCVatoPayViewController.h"
#import "FCVatoPayCashViewController.h"
#import "FCVatoPayCoinViewController.h"

NSString *const topupSuccessNotification = NOTIFICATION_TRANSFER_MONEY_COMPLETED;

@interface FCVatoPayViewController ()
@property (strong, nonatomic) FCBalance* balance;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblCashAmount;

@end

@implementation FCVatoPayViewController

- (instancetype) init {
    NSString* name = NSStringFromClass([self class]);
    self = (FCVatoPayViewController*)[[NavigatorHelper shareInstance] getViewControllerById: name inStoryboard:@"FCWalletViewController"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Ví tài xế";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getBalance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCancelCreatePIN) name:NOTIFICATION_TRANSFER_MONEY_COMPLETED object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TRANSFER_MONEY_COMPLETED object:nil];
}

- (void) onCancelCreatePIN {
    [self getBalance];
}

- (void) getBalance {
    [IndicatorUtils show];
    [APICall apiGetMyBalance:^(FCBalance * balance) {
        [IndicatorUtils dissmiss];
        self.balance = balance;
        [self reloadView];
    }];
}

- (void) reloadView {
    if (!self.balance) {
        self.tableView.allowsSelection = NO;
        return;
    }
    NSInteger cash = self.balance.hardCashPending + self.balance.hardCash;
    NSInteger coin = self.balance.creditPending + self.balance.credit;
    self.lblCashAmount.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:cash withSeperator:@","]];
    self.lblCreditAmount.text = [NSString stringWithFormat:@"%@", [self formatPrice:coin withSeperator:@","]];
}

//- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    UIViewController* vc = segue.destinationViewController;
//    if ([segue.identifier isEqualToString:@"segueToCredit"]) {
//        FCVatoPayCoinViewController* des = (FCVatoPayCoinViewController*) vc;
//        des.balance = self.balance;
//        
//        [[RACObserve(des, balance) distinctUntilChanged] subscribeNext:^(FCBalance* x) {
//            if (x) {
//                self.balance = x;
//                [self reloadView];
//            }
//        }];
//    }
//    else {
//        FCVatoPayCashViewController* des = (FCVatoPayCashViewController*) vc;
//        des.balance = self.balance;
//        
//        [[RACObserve(des, balance) distinctUntilChanged] subscribeNext:^(FCBalance* x) {
//            if (x) {
//                self.balance = x;
//                [self reloadView];
//            }
//        }];
//    }
//}

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

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
    return 18;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            self.walletTripObjecWrapper = [[WalletTripObjcWrapper alloc] initWith:self];
            [self.walletTripObjecWrapper presentVCWithBalance:self.balance];
            
            
        case 1:
            self.walletPointObjcWrapper = [[WalletPointObjcWrapper alloc] initWith:self];
            [self.walletPointObjcWrapper present];
    }
    
    @weakify(self)
    [self.walletTripObjecWrapper setUpdateBalance:^{
        @strongify(self)
        [self getBalance];
    }];
    [self.walletPointObjcWrapper setUpdateBalance:^{
        @strongify(self)
        [self getBalance];
    }];
    
}

@end
