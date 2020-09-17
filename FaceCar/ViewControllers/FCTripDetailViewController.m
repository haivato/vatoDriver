//
//  FCTripDetailViewController.m
//  FC
//
//  Created by facecar on 6/24/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTripDetailViewController.h"
#import "FCTripHistory.h"
#import "APICall.h"
#import "NSObject+Helper.h"
#import "FCWayPoint.h"

#import "UIView+Border.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

#import "FCPointView.h"

@import Masonry;
@interface FCTripDetailViewController ()
@property (strong, nonatomic) FCTripHistory *tripHistory;

//client information
@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@property (weak, nonatomic) IBOutlet FCLabel *lblPaymentOption;
@property (weak, nonatomic) IBOutlet FCLabel *lblPromotion;
@property (weak, nonatomic) IBOutlet UILabel *lblTripStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *viewTripStatus;


//trip
@property (strong, nonatomic) IBOutlet UILabel *labelTripCode;
@property (strong, nonatomic) IBOutlet UILabel *labelAddressFrom;
@property (strong, nonatomic) IBOutlet UILabel *labelAddressTo;
@property (strong, nonatomic) IBOutlet UILabel *labelDistance;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceName;

// Generral
@property (weak, nonatomic) IBOutlet UILabel *lblGenerralSummaryFare; // tổng cước phí
@property (weak, nonatomic) IBOutlet UILabel *lblGenerralClientPay; // Khách trả
@property (weak, nonatomic) IBOutlet UILabel *lblGenerralTitleClientPay; // khách trả (title)


// Detail
@property (weak, nonatomic) IBOutlet UILabel *lblSummaryClientPay; // Giá cước (đã trừ km)
@property (weak, nonatomic) IBOutlet UILabel *lblSumaryPromo; // km khách hàng
@property (weak, nonatomic) IBOutlet UILabel *labelSummaryIncreaseAnTip; // thưởng chuyến đi
@property (weak, nonatomic) IBOutlet UILabel *labelSummaryTotalPrice; // tong cuoc phi
@property (weak, nonatomic) IBOutlet UILabel *labelSummaryTax; // thuế
@property (weak, nonatomic) IBOutlet UILabel *labelSummaryVivuPrice; // chiết khấu
@property (weak, nonatomic) IBOutlet UILabel *labelSummaryRealPrice; // thực nhận

// client summary
@property (weak, nonatomic) IBOutlet UILabel *lblSummaryClientTripFare; // giá cước (đã trừ km)
@property (weak, nonatomic) IBOutlet UILabel *lblSummaryClientPromotion; // khuyến mãi khách hàng
@property (weak, nonatomic) IBOutlet UILabel *lblSummaryClientTip; // thưởng chuyến đi
@property (weak, nonatomic) IBOutlet UILabel *lblSummaryClientTotalPay; // khách trả
@property (weak, nonatomic) IBOutlet UILabel *lblTitleClientPay;

@property (weak, nonatomic) IBOutlet UIImageView *iconStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *baseOderFoodLabel;
@property (weak, nonatomic) IBOutlet UILabel *baseOderFoodSummaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *transportTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *transportSummaryTextLabel;

@property (weak, nonatomic) IBOutlet UIStackView *addressesStackView;

@property (nonatomic) NSInteger baseGrandTotal;

@property (strong, nonatomic) RequestQuickSupportObjcWrapper *requestQuickSupport;
@end

@implementation FCTripDetailViewController {
    BOOL _isExpained;
    BOOL _isTripCompleted;
}

- (instancetype) initView:(FCTripHistory*)trip {
    self = [[UIStoryboard storyboardWithName:@"FCTripDetailViewController"
                                      bundle:nil] instantiateViewControllerWithIdentifier:@"TripDetail"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(onClosePress:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Chi tiết";
    
    self.tripHistory = trip;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    _isTripCompleted = self.tripHistory.status == TripStatusCompleted;
    
    // trip info
    [self.labelTripCode setText:[NSString stringWithFormat:@"Mã chuyến: %@", self.tripHistory.tripCode]];
    NSMutableArray* start = [[NSMutableArray alloc] initWithObjects:self.tripHistory.startName, self.tripHistory.startAddress, nil];
    [self.labelAddressFrom setText:[start componentsJoinedByString:@", "]];
    NSMutableArray* end = [[NSMutableArray alloc] initWithObjects:self.tripHistory.endName, self.tripHistory.endAddress, nil];
    if (end.count > 0) {
        [self.labelAddressTo setText:[end componentsJoinedByString:@", "]];
    }
    else {
        [self.labelAddressTo setText:@"Điểm đến theo lộ trình thực tế"];
        self.labelAddressTo.textColor = [UIColor lightGrayColor];
    }
    
    [self.labelDistance setText:[NSString stringWithFormat:@"%.1f km", self.tripHistory.distance / 1000.0f]];
    [self.labelTime setText:[NSString stringWithFormat:@"%ld phút", (long) (self.tripHistory.duration / 60)]];
    [self.lblServiceName setText:[self.tripHistory localizeServiceName]];
    [self.lblTime setText:[self getTimeString:self.tripHistory.createdAt]];
    
    // trans info
    [self apiGetDetail];
    
    // note
    self.lblNote.text = _tripHistory.note;
    
    [self showTripStatus];
    
    if (_tripHistory.status == TripStatusCompleted) {
        self.iconStatus.hidden = NO;
        self.lblStatus.hidden = NO;
        
        if (_tripHistory.eval == 0) {
            self.iconStatus.image = [UIImage imageNamed:@"ic_evalute_3"];
            self.lblStatus.text = @"Hợp lệ";
            self.lblStatus.textColor = GREEN_COLOR;
        }
        else {
            if (_tripHistory.confirmEvaluate) {
                self.iconStatus.image = [UIImage imageNamed:@"ic_evalute_2"];
                self.lblStatus.text = @"Không hợp lệ";
                self.lblStatus.textColor = RED_COLOR;
            }
            else {
                self.iconStatus.image = [UIImage imageNamed:@"ic_evalute_1"];
                self.lblStatus.text = @"Đang chờ duyệt";
                self.lblStatus.textColor = ORANGE_COLOR ;
            }
        }
    }
    else {
        self.iconStatus.hidden = YES;
        self.lblStatus.hidden = YES;
    }
    
    _requestQuickSupport = [[RequestQuickSupportObjcWrapper alloc] initWith:self serviceName:[self.tripHistory localizeServiceName] tripCode:self.tripHistory.tripCode];
}

- (void) showTripStatus {
    switch (self.tripHistory.statusDetail) {
        case BookStatusClientCreateBook:
        case BookStatusDriverAccepted:
        case BookStatusClientAgreed:
        case BookStatusStarted:
            [self.lblTripStatus setText:@"Đang trong chuyến đi."];
            break;
            
        case BookStatusClientTimeout:
        case BookStatusClientCancelInBook:
        case BookStatusClientCancelIntrip:
            [self.lblTripStatus setText:@"Yêu cầu đặt xe bị huỷ bởi khách."];
            break;
            
        case BookStatusAdminCancel:
            [self.lblTripStatus setText:@"Yêu cầu đặt xe bị huỷ bởi admin."];
            break;
            
        case BookStatusDriverCancelInBook:
            [self.lblTripStatus setText:@"Yêu cầu đặt xe bị bỏ qua bởi tài xế."];
            break;
            
        case BookStatusDriverCancelIntrip:
            [self.lblTripStatus setText:@"Yêu cầu đặt xe bị huỷ bởi tài xế ."];
            break;
            
        case BookStatusDriverMissing:
            [self.lblTripStatus setText:@"Yêu cầu đặt xe bị bỏ trôi."];
            break;
            
        default:
            [self.lblTripStatus setText:@""];
            [self.viewTripStatus setHidden:YES];
            break;
    }
}

- (void) reloadDetailData: (NSMutableArray*) transactions {
    
    // payment option
    self.lblPaymentOption.hidden = NO;
    switch (self.tripHistory.payment) {
        case PaymentMethodVisa:
        case PaymentMethodMastercard:
        case PaymentMethodATM:
            self.lblPaymentOption.text = @"  Thẻ  ";
            self.lblPaymentOption.textColor = UIColor.whiteColor;
            self.lblPaymentOption.backgroundColor = ORANGE_COLOR;
            break;

        case PaymentMethodVATOPay:
            self.lblPaymentOption.text = @"  VATOPay  ";
            self.lblPaymentOption.textColor = UIColor.whiteColor;
            self.lblPaymentOption.backgroundColor = ORANGE_COLOR;
            break;

        default:
            self.lblPaymentOption.text = @"  Tiền mặt  ";
            self.lblPaymentOption.textColor = UIColor.blackColor;
            self.lblPaymentOption.backgroundColor = LIGHT_GRAY;
            break;
    }
    
    // promotion
    if (self.tripHistory.promotionModifierId != 0 || self.tripHistory.fareClientSupport > 0) {
        self.lblPromotion.hidden = NO;
    }
    else {
        self.lblPromotion.hidden = YES;
    }
    
    
    // vivu fee
    long totalFee = 0;
    long totalClientSupport = 0;
    long totalDriverSupport = 0;
    long tax = 0;
    for (FCInvoice* invoice in transactions) {
        if (invoice.type == TRIP_FEE) {
            totalFee += (invoice.amount);
        }
        else if (invoice.type == TRIP_CLIENT_SUPPORT_TO_CLIENT || invoice.type == TRIP_CLIENT_SUPPORT_TO_DRIVER) {
            totalClientSupport += (invoice.amount);
        }
        else if (invoice.type == TRIP_DRIVER_SUPPORT) {
            totalDriverSupport += (invoice.amount);
        }
        else if (invoice.type == TRIP_TAX) {
            tax += (invoice.amount);
        }
    }
    
    NSInteger originPrice = self.tripHistory.price;
    NSInteger totalFare = MAX(self.tripHistory.price, self.tripHistory.farePrice);
    NSInteger totalPrice = totalFare + self.tripHistory.additionPrice;
    if ([self.tripHistory deliveryFoodMode]) {
        totalPrice = totalPrice + self.baseGrandTotal;
    }
    if (self.tripHistory.statusDetail == BookStatusDriverCancelInBook ||
        self.tripHistory.statusDetail == BookStatusDriverCancelIntrip) {
        self.labelSummaryRealPrice.text = [self formatPrice:-totalFee];
    }
    else if (self.tripHistory.statusDetail == BookStatusDriverMissing) {
        self.labelSummaryRealPrice.text = [self formatPrice:-totalFee];
    }
    else if (self.tripHistory.statusDetail == BookStatusCompleted
             || self.tripHistory.statusDetail == BookStatuDeliveryFail) {
        NSInteger clientPromotion = MIN(totalClientSupport, totalFare);
        NSInteger clientpay = MAX(totalPrice - clientPromotion, 0);
        NSInteger increaseAndTip = _tripHistory.additionPrice + MAX(_tripHistory.farePrice - _tripHistory.price, 0);
        
        //////////////////////////////
        //// Biên nhận tài xế ////////
        
        // Giá cước
        self.lblSummaryClientPay.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:originPrice withSeperator:@","]];
        
        // Khuyến mãi khách hàng
        [self.lblSumaryPromo setText:[NSString stringWithFormat:@"%@đ", [self formatPrice: clientPromotion withSeperator:@","]]];
        
        // thưởng chuyến đi
        self.labelSummaryIncreaseAnTip.text = [NSString stringWithFormat:@"%@đ", [self formatPrice: increaseAndTip withSeperator:@","]];
        
        // Tổng cước phí
        [self.labelSummaryTotalPrice setText:[NSString stringWithFormat:@"%@đ", [self formatPrice:totalPrice withSeperator:@","]]];
        
        // Thuế
        if (tax > 0)
            [self.labelSummaryTax setText:[NSString stringWithFormat:@"-%@đ", [self formatPrice:tax withSeperator:@","]]];
        
        // Thưởng lái xe
//        [self.lblSummaryDriverSupport setText:[NSString stringWithFormat:@"%@đ", [self formatPrice:totalDriverSupport withSeperator:@","]]];
        
        // Chiết khấu
        self.labelSummaryVivuPrice.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:-totalFee withSeperator:@","]];
        
        // Thực nhận
        self.labelSummaryRealPrice.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:MAX(totalPrice - tax - totalFee, 0) withSeperator:@","]];
        
        
        if ([self.tripHistory deliveryFoodMode]) {
            self.transportTextLabel.text = @"Phí giao hàng";
            self.transportSummaryTextLabel.text = @"Phí giao hàng";
            self.baseOderFoodLabel.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:MAX(self.baseGrandTotal, 0) withSeperator:@","]];
            self.baseOderFoodSummaryLabel.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:MAX(self.baseGrandTotal, 0) withSeperator:@","]];
        }
        ////////////////////////////////
        //// bien nhan khach hang///////
        
        // giá cước (đã trừ km)
        self.lblSummaryClientTripFare.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:MAX(originPrice, 0) withSeperator:@","]];
        
        // Tổng cước phí
        // self.lblClientSummaryTotalPrice.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:originPrice withSeperator:@","]];
        
        // KM khách hàng
        if (clientPromotion > 0)
            self.lblSummaryClientPromotion.text = [NSString stringWithFormat:@"-%@đ", [self formatPrice:clientPromotion withSeperator:@","]];
        
        // thưởng chuyến đi
        self.lblSummaryClientTip.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:increaseAndTip withSeperator:@","]];
        
        // Khach trả
        self.lblSummaryClientTotalPay.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:clientpay withSeperator:@","]];
        switch (self.tripHistory.payment) {
            case PaymentMethodVisa:
            case PaymentMethodMastercard:
            case PaymentMethodATM:
                self.lblTitleClientPay.text = @"Khách trả (Thẻ)";
                self.lblGenerralTitleClientPay.text = @"Khách trả (Thẻ)";
                break;

            case PaymentMethodVATOPay:
                self.lblTitleClientPay.text = @"Khách trả (VATOPay)";
                self.lblGenerralTitleClientPay.text = @"Khách trả (VATOPay)";
                break;

            default:
                self.lblTitleClientPay.text = @"Khách trả (Tiền mặt)";
                self.lblGenerralTitleClientPay.text = @"Khách trả (Tiền mặt)";
                break;
        }
        
        //////////////////////////////
        ///// Generral ///////////////
        
        // Tổng cước phí
        [self.lblGenerralSummaryFare setText:[NSString stringWithFormat:@"%@đ", [self formatPrice:totalPrice withSeperator:@","]]];
        
        // Khach trả (Tiền mặt)
        self.lblGenerralClientPay.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:clientpay withSeperator:@","]];
    }
}

- (void) apiGetDetail {
    [IndicatorUtils show];
    @weakify(self);
    [[APIHelper shareInstance] get:API_GET_TRIP_DETAIL
                            params:@{@"id":self.tripHistory.id}
                          complete:^(FCResponse *response, NSError *e) {
        [IndicatorUtils dissmiss];
        if (response.status == APIStatusOK && response.data) {
            @strongify(self);
            NSMutableArray* listTrans = [[NSMutableArray alloc] init];
            NSArray* array = [response.data objectForKey:@"transactions"];
            for (NSDictionary* d in array) {
                FCInvoice* invoice = [[FCInvoice alloc] initWithDictionary:d
                                                                     error:nil];
                if (invoice && [invoice.referId isEqualToString: self.tripHistory.id]) {
                    [listTrans addObject:invoice];
                }
            }
            
            NSDictionary* dictTrip = [response.data objectForKey:@"trip"];
            FCBookInfo* tripInfo = [[FCBookInfo alloc] initWithDictionary:dictTrip error:nil];
            [self setupAddressView:tripInfo.wayPoints];
            
            [self.tableView reloadData];
            if ([self.tripHistory deliveryFoodMode]) {
                [self getSaleOderFood:listTrans];
            } else {
                [self reloadDetailData: listTrans];
            }
        }
    }];
}

- (void)setupAddressView:(NSArray<FCWayPoint*> *) wayPoints {
    for (UIView *v in [_addressesStackView subviews]) {
        [_addressesStackView removeArrangedSubview:v];
        [v removeFromSuperview];
    }
    
    [_addressesStackView addArrangedSubview:[self getPointView:self.tripHistory.startAddress origin:true]];
    [_addressesStackView addArrangedSubview:[self getVerticalLineView]];
    
    for (NSDictionary* dict in wayPoints) {
        if (dict != nil) {
            FCWayPoint *wp = [[FCWayPoint alloc] initWithDictionary:dict error:nil];
            [_addressesStackView addArrangedSubview:[self getPointView:wp.address origin:false]];
            [_addressesStackView addArrangedSubview:[self getVerticalLineView]];
        }
    }
    
    [_addressesStackView addArrangedSubview:[self getPointView:self.tripHistory.endAddress origin:false]];
}

- (FCPointView *)getPointView: (NSString *)address origin:(BOOL) isOrigin {
    FCPointView *origin = [[[NSBundle mainBundle] loadNibNamed:@"FCPointView" owner:self options:nil] objectAtIndex:0];
    [origin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
    }];
    [origin setupDisplay:address origin:isOrigin];
    return origin;
}


- (UIView *)getVerticalLineView {
    UIView* view = [[UIView alloc] init];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_vertical_4dots"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(10);
    }];
    [view addSubview:imageView];

    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(2);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(7);
    }];
    return view;
}

- (void)getSaleOderFood:(NSMutableArray *)listTrans {
    [IndicatorUtils show];
    @weakify(self);
    [[TripManagerHelper shared] getTripFoodDetailWithTripId:self.tripHistory.id complete:^(NSInteger baseGrandTotal, NSError *error) {
        [IndicatorUtils dissmiss];
        @strongify(self);
        self.baseGrandTotal = baseGrandTotal;
        [self reloadDetailData: listTrans];
    }];
}

- (void) onClosePress: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onExpainPressed:(id)sender {
    _isExpained = YES;
    [self.tableView reloadData];
}

- (IBAction)onCollapPressed:(id)sender {
    _isExpained = NO;
    [self.tableView reloadData];
}

- (IBAction)onSupportPressed:(id)sender {
    if(_requestQuickSupport) {
        [_requestQuickSupport present];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_tripHistory.status != TripStatusCompleted) {
        if (indexPath.section == 0 && indexPath.row == 3) {
            return 0;
        }
    }
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        return 0;
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40;
    }
    
//    if (section == 1) {
//        return 0.1f;
//    }
//
//    if (section == 2) {
//        if (_isExpained) {
//            return 0.1f;
//        }
//        return 5.0f;
//    }
//
//    if (section == 3) {
//        if (_isExpained) {
//            return 0.1f;
//        }
//        return 5.0f;
//    }
    
    return 0.01f;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(16, 0, [UIScreen mainScreen].bounds.size.width - 16, 40)];
        view.backgroundColor = UIColorFromRGB(0xF0EFF5);
        
        UILabel* lblVersion = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
        lblVersion.font = [UIFont systemFontOfSize:10];
        [lblVersion setTextAlignment:NSTextAlignmentCenter];
        lblVersion.textColor = UIColor.darkGrayColor;
        FCDriver *driver = [[UserDataHelper shareInstance] getCurrentUser];
        lblVersion.text = [NSString stringWithFormat:@"%li | %@", (long)driver.user.id, APP_VERSION_STRING];
        [view addSubview:lblVersion];
        
        UILabel* lableTime = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, [UIScreen mainScreen].bounds.size.width/2, 40)];
        lableTime.font = [UIFont systemFontOfSize:12];
        lableTime.textColor = UIColor.darkGrayColor;
        lableTime.text = [self getTimeString:self.tripHistory.createdAt];
        [view addSubview:lableTime];
        
        UILabel* lableCode = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, 40)];
        lableCode.textAlignment = NSTextAlignmentRight;
        lableCode.font = [UIFont systemFontOfSize:12];
        lableCode.textColor = UIColor.darkGrayColor;
        lableCode.text = [NSString stringWithFormat:@"Mã chuyến: %@", self.tripHistory.tripCode];
        [view addSubview:lableCode];
        
        
        
        return view;
    }
    
    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL hasNote = _tripHistory.note.length > 0;
    // info trip
    if (section == 0) {
        if (hasNote) {
            return 5;
        }
        return 4;
    }
    
    // trip status not finished (tx huy, khach huy,...)
    if (section == 1) {
        // chuyến hoàn thành thì hide thông tin này
        if (_isTripCompleted) {
            return 0;
        }
        return 2;
    }
    
    // Nếu chuyến hoàn thành thì hiển thị các thông tin về phí và thu nhập
    // ngược lại thì ẩn
    if (_isTripCompleted) {
        // general info
        if (section == 2) {
            if (_isExpained) {
                return 0; // hide
            }
            return 6;
        }
        
        // detail info
        if (section == 3) {
            if (_isExpained) {
                return 14;
            }
            
            return 0;
        }
    }
    
    return 0;
}

@end
