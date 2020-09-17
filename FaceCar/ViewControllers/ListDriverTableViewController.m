//
//  ListDriverTableViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/4/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "ListDriverTableViewController.h"
#import "DriverTableViewCell.h"
#import "DriverDetailViewController.h"
#import "AFNetworkingHelper.h"

@interface ListDriverTableViewController () <FilterDelegate>

@end

@implementation ListDriverTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    [self getDrivers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Handler
- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_DRIVER_DETAIL]) {
        DriverDetailViewController* vc = segue.destinationViewController;
        vc.driver = (FCDriver*)sender;
        vc.placeStart = self.placeStart;
        vc.placeEnd = self.placeEnd;
        vc.price = self.price;
    }
    else if ([segue.identifier isEqualToString:SEGUE_DRIVER_SEARCH]) {
        FilterViewController* des = segue.destinationViewController;
        des.currentFilter = self.currentFilter;
        des.delegate = self;
    }
}

- (void) getDrivers {
    [IndicatorUtils show];
    
    NSInteger carGroup = self.currentFilter.carGroup.id;
    if (carGroup == 0) {
        carGroup = 1;
    }
    
    NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSNumber numberWithDouble:self.placeStart.location.lat], @"lat",
                            [NSNumber numberWithDouble:self.placeStart.location.lon], @"lon",
                            [NSString stringWithFormat:@"%ldkm",(long)self.currentFilter.distance] , @"radius",
                            self.currentFilter.status, @"status",
                            [NSNumber numberWithInteger:carGroup], @"carGroup",
                            [NSNumber numberWithInteger:self.cartype], @"carType",
                            [FIRAuth auth].currentUser.uid ? [FIRAuth auth].currentUser.uid : @"", @"userId",
                            [NSNumber numberWithBool:self.currentFilter.favorite], @"isFavorite",
                            [NSNumber numberWithBool:self.currentFilter.blackList], @"isBlacklist",
                            @"sort", @"location asc",
                            [NSNumber numberWithInt:1], @"from",
                            [NSNumber numberWithInt:100], @"size", nil];
    
    CLLocation* currentLo = [[CLLocation alloc] initWithLatitude:self.placeStart.location.lat longitude:self.placeStart.location.lon];
    [[AFNetworkingHelper shareInstance] apiSearchDriver:params completeHandler:^(NSMutableArray * listDriver) {
        [self.listDrivers removeAllObjects];
        NSArray* arr = [listDriver sortedArrayUsingComparator:^NSComparisonResult(FCDriver* obj1, FCDriver* obj2) {
            NSInteger dis1 = [self getDistance:[[CLLocation alloc] initWithLatitude:obj1.location.lat longitude:obj1.location.lon] fromMe:currentLo];
            NSInteger dis2 = [self getDistance:[[CLLocation alloc] initWithLatitude:obj2.location.lat longitude:obj2.location.lon] fromMe:currentLo];
            
            return [[NSNumber numberWithInteger:dis1] compare:[NSNumber numberWithInteger:dis2]];
        }];
        
        self.listDrivers = [NSMutableArray arrayWithArray:arr];
        [self.tableView reloadData];
        [IndicatorUtils dissmiss];
    }];


    /*[[FirebaseHelper shareInstance] getDrivers:self.currentFilter fromLocation:[[CLLocation alloc] initWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude] handler:^(NSMutableArray * drivers) {
        [self.listDrivers removeAllObjects];
        self.listDrivers = drivers;
        [self.tableView reloadData];
        [IndicatorUtils dissmiss];
    }];*/
}

#pragma mark - Filter Delegate
- (void) onFilterSelected:(FCFilter *)filter {
    self.currentFilter = filter;
    
    // callback
    [self.delegate onFilterSelected:self.currentFilter];
    
    // reget list driver
    [self getDrivers];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;//self.listDrivers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DriverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DriverTableViewCell class]) forIndexPath:indexPath];
//    FCDriver* driver = [self.listDrivers objectAtIndex:indexPath.row];
    [cell loadDriverInfo:[FirebaseHelper shareInstance].currentDriver fromLocation:[[CLLocation alloc] initWithLatitude:self.placeStart.location.lat longitude:self.placeStart.location.lon]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:SEGUE_DRIVER_DETAIL sender:[self.listDrivers objectAtIndex:indexPath.row]];
}

@end
