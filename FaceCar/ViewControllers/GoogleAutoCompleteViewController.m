//
//  GoogleAutoCompleteViewController.m
//  FaceCar
//
//  Created by facecar on 5/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "GoogleAutoCompleteViewController.h"
#import "FCGooglePlaceTableViewCell.h"

#define CELL @"FCGooglePlaceTableViewCell"

@interface GoogleAutoCompleteViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) GMSAutocompleteViewController *acController;

@property (strong, nonatomic) NSArray* listPlace;
@property (strong, nonatomic) NSArray* listHistory;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@end

@implementation GoogleAutoCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:CELL bundle:nil] forCellReuseIdentifier:CELL];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.searchBar becomeFirstResponder];
    
    [RACObserve(self.googleViewModel, listPlace) subscribeNext:^(NSArray* x) {
        self.listPlace = x;
        [self.tableView reloadData];
    }];
    
    [RACObserve(self.googleViewModel, listHistory) subscribeNext:^(id x) {
        self.listHistory = x;
        [self.tableView reloadData];
    }];
    
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTap)];
//    [self.tableView addGestureRecognizer:tap];

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [IndicatorUtils dissmiss];
}

- (instancetype) initViewController {
    GoogleAutoCompleteViewController* vc = (GoogleAutoCompleteViewController*) [self initWithNibName:@"GoogleAutoCompleteViewController" bundle:nil];
    return vc;
}

- (void) tableViewTap {
    [self.searchBar resignFirstResponder];
}

- (void) setMapview:(FCGGMapView *)mapview {
    _mapview = mapview;
    self.googleViewModel = [[GoogleViewModel alloc] init:self.mapview];
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Searchbar delegate
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.googleViewModel queryPlace:searchText];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView Delegate
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCGooglePlaceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL forIndexPath:indexPath];
    FCPlace* data = [self.listPlace objectAtIndex:indexPath.row];
    
    if (data) {
        [cell loadData:data];
    }
    else {
        FCPlaceHistory* his = [self.listHistory objectAtIndex:indexPath.row];
        [cell loadDataForHis:his];
    }
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listPlace ? self.listPlace.count : self.listHistory.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.googleViewModel didSelectedPlace:indexPath];
    [IndicatorUtils show];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

@end
