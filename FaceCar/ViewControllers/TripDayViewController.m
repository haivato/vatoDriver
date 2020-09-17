//
//  TripDayViewController.m
//  FC
//
//  Created by Son Dinh on 5/22/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "TripDayViewController.h"
#import "UIView+Border.h"
#import "FCTripDayTableViewCell.h"
#import "FCTripDetailViewController.h"
#import "FacecarNavigationViewController.h"
#import "APICall.h"
#import "UITableView+ENFooterActivityIndicatorView.h"
#import "FCWarningNofifycationView.h"

#define CELL @"FCTripDayTableViewCell"

@interface TripDayViewController () <FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *listTripHistory;
@end

@implementation TripDayViewController {
    FCWarningNofifycationView* _notifyView;
    UIRefreshControl* refresh;
    NSInteger _page;
    BOOL _more;
    BOOL _loadMoring;
    long long _from;
    long long _to;
}

- (instancetype) initViewController {
    self = [[UIStoryboard storyboardWithName:@"TripManager"
                                      bundle:nil] instantiateViewControllerWithIdentifier:@"TripDayViewController"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Lịch sử chuyến đi";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listTripHistory = [[NSMutableArray alloc] init];
    self.calendar.scope = FSCalendarScopeWeek;
    self.calendar.calendarHeaderView.hidden = TRUE;
    
    [self.tableView registerNib:[UINib nibWithNibName:CELL bundle:nil]
         forCellReuseIdentifier:CELL];
    
    // header
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        refresh =  [[UIRefreshControl alloc] init];
        [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
        self.tableView.refreshControl = refresh;
    }
    
    // footer
    [self.tableView setTableScrolledDownBlock:^void() {
        if (_more) {
            if (![self.tableView footerActivityIndicatorView])
                [self.tableView addFooterActivityIndicatorWithHeight:80.f];
            
            if (!_loadMoring) {
                _page ++;
                _loadMoring = TRUE;
                [self getListTrip];
            }
        }
        else {
            [self.tableView removeFooterActivityIndicator];
        }
    }];
    
    // get data
    [IndicatorUtils show];
    [self loadTripHistory:[self getCurrentDate]];
    
    //show appp information
    FCDriver *driver = [[UserDataHelper shareInstance] getCurrentUser];
    [self.labelAppVersion setText:[NSString stringWithFormat:@"%li | %@", (long)driver.user.id, APP_VERSION_STRING]];
}

- (void) onRefresh: (id) sender {
    [refresh endRefreshing];
}

- (BOOL) isCurrentDay {
    return [self theSameDay:[self getCurrentTimeStamp] and:_from];
}

- (void) showSummaryView: (NSInteger) totalTrip
                 revenue: (NSInteger) money {
    [self.labelCompleteTripCount setText:[NSString stringWithFormat:@"%ld chuyến", totalTrip]];
    [self.labelTotalIncome setText:[NSString stringWithFormat:@"%@đ", [self formatPrice:money withSeperator:@","]]];
}

- (void) apiGetSumary {
    // check from local first
    NSNumber* money = [[UserDataHelper shareInstance] getTripSumaryAmount:_from];
    NSNumber* tripCount = [[UserDataHelper shareInstance] getTripSumaryCount:_from];
    if (tripCount && ![self isCurrentDay]) {
        [self showSummaryView:[tripCount integerValue]
                      revenue:[money integerValue]];
        return;
    }
    
    [[APIHelper shareInstance] get:API_GET_TRIP_SUMARY_iN_DAY
                            params:@{@"date" : @(_from)}
                          complete:^(FCResponse *response, NSError *e) {
                              if (response.status == APIStatusOK && response.data) {
                                  NSInteger money = [[response.data objectForKey:@"revenue"] integerValue];
                                  NSInteger tripCount = [[response.data objectForKey:@"tripCount"] integerValue];
                                  
                                  [self showSummaryView:tripCount
                                                revenue:money];
                                  
                                  // cache
                                  [[UserDataHelper shareInstance] saveSumaryTrip:tripCount
                                                                     totalAmount:money
                                                                          forday:_from];
                              }
                          }];
}

- (void) getListTrip {
    // check from local first
    NSMutableArray* arr = [[UserDataHelper shareInstance] getListTripsForDay:_from];
    _more = [[UserDataHelper shareInstance] hasMoreTripsForDay:_from];
    if (arr && ![self isCurrentDay] && arr.count > self.listTripHistory.count) {
        [IndicatorUtils dissmiss];
        if (_page == 0) {
            [self.listTripHistory removeAllObjects];
        }
        
        self.listTripHistory = arr;
        [self sortListTripHistory];
        [self.tableView reloadData];
        return;
    }
    
    NSDictionary* body = @{@"from": @(_from),
                           @"to": @(_to),
                           @"page": @(_page),
                           @"size": @10};
    
    [[APIHelper shareInstance] get:API_GET_TRIP_DAY
                            params:body
                          complete:^(FCResponse *response, NSError *e) {
                              [IndicatorUtils dissmiss];
                              @try {
                                  NSMutableArray* list = [[NSMutableArray alloc] init];
                                  NSDictionary *data = response.data;
                                  NSArray* datas = [data objectForKey:@"trips"];
                                  BOOL more = [[data objectForKey:@"more"] boolValue];
                                  for (id item in datas) {
                                      NSError* err;
                                      FCTripHistory* invoice = [[FCTripHistory alloc] initWithDictionary:item error:&err];
                                      if (invoice) {
                                          [list addObject:invoice];
                                      }
                                  }
                                  
                                  
                                  _more = more;
                                  _loadMoring = NO;
                                  [self.listTripHistory addObjectsFromArray: list];
                                  
                                  [self sortListTripHistory];
                                  [self.tableView reloadData];
                                  [self checkData];
                                  
                                  // cache data
                                  [[UserDataHelper shareInstance] saveTripForDay:_from
                                                                           trips:self.listTripHistory
                                                                         hasMore:_more];
                              }
                              @catch (NSException* e) {
                                  DLog(@"Error: %@", e);
                              }
                          }];
}

- (void) checkData {
//    if (self.listTripHistory.count == 0) {
//        _notifyView = [[FCWarningNofifycationView alloc] init];
//        _notifyView.lblTitle.text = @"";
//        _notifyView.bgColor = [UIColor whiteColor];
//        _notifyView.messColor = [UIColor darkGrayColor];
//        [_notifyView show:self.tableView
//             image:nil
//             title:nil
//           message:@"Bạn không có chuyến đi trong ngày này!"];
//        [self.tableView setScrollEnabled:NO];
//    }
}

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) loadTripHistory:(NSDate*)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/YYYY";
    [self.labelTitle setText:[NSString stringWithFormat:@"Tổng kết ngày %@", [dateFormatter stringFromDate:date]]];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    NSDate * dateFrom = [NSDate getDateWithYear:[components year]
                                          month:[components month]
                                            day:[components day]];
    NSDate *dateTo = dateFrom;
    
    if (_from == [self getTimestampOfDate:dateFrom]) {
        return;
    }
    
    _page = 0;
    _more = NO;
    _from = [self getTimestampOfDate:dateFrom];
    _to = [self getTimestampOfDate:dateTo]+24*3600*1000;
    [self.listTripHistory removeAllObjects];
    [self.tableView reloadData];
    [self getListTrip];
    [self apiGetSumary];
}

- (void)sortListTripHistory {
    NSArray* arr = [self.listTripHistory sortedArrayUsingComparator:^NSComparisonResult(FCTripHistory* obj1, FCTripHistory* obj2) {
        return obj1.createdAt < obj2.createdAt;
    }];
    
    self.listTripHistory = [NSMutableArray arrayWithArray:arr];
}

#pragma mark - FSCalendarDelegate
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    self.calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    
    [self.view layoutIfNeeded];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    [self loadTripHistory:date];
}

- (NSDate*) maximumDateForCalendar:(FSCalendar *)calendar {
    return [self getCurrentDate];
}

#pragma mark - Tableview Delegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.listTripHistory)
    {
        return self.listTripHistory.count;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 191;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCTripDayTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL forIndexPath:indexPath];
    if (self.listTripHistory)
    {
        FCTripHistory *tripHistory = [self.listTripHistory objectAtIndex:indexPath.row];
        [cell updateData:tripHistory];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCTripHistory *tripHistory = [self.listTripHistory objectAtIndex:indexPath.row];
    
    FCTripDetailViewController* detailVC = [[FCTripDetailViewController alloc] initView:tripHistory];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:detailVC];
    [navController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView tableViewDidScroll];
}
@end

