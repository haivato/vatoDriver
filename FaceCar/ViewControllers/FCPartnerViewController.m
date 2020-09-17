//
//  FCPartnerViewController.m
//  FC
//
//  Created by facecar on 12/22/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPartnerViewController.h"
#import "FCPartnerTableViewCell.h"
#import "FCPartnerViewModel.h"
#import "FCWarningNofifycationView.h"

#define kCellIdentify @"FCPartnerTableViewCell"
#define kRowHeight 80

@interface FCPartnerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;

@end

@implementation FCPartnerViewController {
    CGRect _fromFrame;
    CGRect _targetFrame;
    NSArray* _listPartner;
    NSMutableDictionary* _listPartnerStatus;
    FCPartnerViewModel* _viewModel;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FCPartnerTableViewCell class]) bundle:nil]
         forCellReuseIdentifier:kCellIdentify];
    
    _viewModel = [[FCPartnerViewModel alloc] init];
    _viewModel.viewController = self;
    [RACObserve(_viewModel, listPartner) subscribeNext:^(NSMutableArray* x) {
        
        if (x && x.count == 0) {
            [self notifyNoPartner];
        }
        _listPartner = x;
        [self.tableView reloadData];
        
        [self loadPartnerStatus];
    }];
}

- (void) loadPartnerStatus {
    [RACObserve(_viewModel, listPartnerStatus) subscribeNext:^(NSMutableDictionary* x) {
        if (x && x.count > 0) {
            _listPartnerStatus = x;
            [self.tableView reloadData];
        }
    }];
}

- (void) notifyNoPartner {
    FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] intView];
    view.bgColor = [UIColor whiteColor];
    view.messColor = [UIColor darkGrayColor];
    [view show:self.view
         image:[UIImage imageNamed:@"partner"]
         title:nil
       message:@"Hiện chưa có hãng taxi nào trong khu vực của bạn. Bạn vui lòng liên hệ tổng đài 19000004 để được hỗ trợ thêm."];
    
    [self.view addSubview:view];
}

- (void) hide {
    [self backPressed:nil];
}

- (IBAction) registerClicked:(id)sender {
    [_viewModel joinToPartner:self.partnerSelected.id
                      handler:^(NSError * error) {
                          if (!error)
                              [self hide];
                      }];
}

#pragma mark - Tableview delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listPartner.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCPartnerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentify
                                                                   forIndexPath:indexPath];
    FCPartner* partner = [_listPartner objectAtIndex:indexPath.row];
    [cell.icon setImageWithUrl:partner.logo
                        holder:cell.icon.image];
    cell.lblName.text = partner.fullname;
    cell.lblDescription.text = partner.slogan;
    
    NSInteger stt = [_viewModel statusForPartner:partner.id];
    cell.userInteractionEnabled = NO;
    cell.lblStatus.textColor = LIGHT_GREEN;
    if (stt == FCPartnerJoinStatusWaitingReview) {
        cell.lblStatus.text = @"Chờ duyệt";
    }
    else if (stt == FCPartnerJoinStatusJoined) {
        cell.lblStatus.text = @"Đã tham gia";
    }
    else if (stt == FCPartnerJoinStatusRejected) {
        cell.lblStatus.text = @"Bị từ chối";
        cell.lblStatus.textColor = [UIColor redColor];
    }
    else if (stt == FCPartnerJoinStatusUnknow) {
        cell.lblStatus.text = EMPTY;
        cell.userInteractionEnabled = YES;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.partnerSelected = [_listPartner objectAtIndex:indexPath.row];

    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
}

@end
