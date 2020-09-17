//
//  TripDayViewController.h
//  FC
//
//  Created by Son Dinh on 5/22/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "TripPageContentViewController.h"
#import <FSCalendar/FSCalendar.h>

@interface TripDayViewController : TripPageContentViewController
@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* calendarHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *genaralView;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelCompleteTripCount;
@property (strong, nonatomic) IBOutlet UILabel *labelTotalIncome;
@property (weak, nonatomic) IBOutlet UILabel *labelAppVersion;


- (instancetype) initViewController;

@end
