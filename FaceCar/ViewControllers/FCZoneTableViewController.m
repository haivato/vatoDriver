//
//  FCZoneTableViewController.m
//  FC
//
//  Created by facecar on 5/6/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCZoneTableViewController.h"
#import "FCZoneTableViewCell.h"

#define ZONE_CELL @"FCZoneTableViewCell"

@interface FCZoneTableViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FCZoneTableViewController

- (instancetype) initView {
    
    self = [self initWithNibName:@"FCZoneTableViewController" bundle:nil];
    [self.navigationItem setTitle:@"Chọn khu vực"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:ZONE_CELL bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:ZONE_CELL];
    
    self.viewModel = [[FCZoneViewModel alloc] initViewModel];
    
    [RACObserve(self.viewModel, listZone) subscribeNext:^(id x) {
        [self.tableView reloadData];
    }];
    
    [RACObserve(self.viewModel, zoneSelected) subscribeNext:^(id x) {
        self.zoneSelected = x;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) backPressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.listZone.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ZONE_CELL forIndexPath:indexPath];
    FCZone* zone = [self.viewModel.listZone objectAtIndex:indexPath.row];
    cell.textLabel.text = zone.name;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel didSelectZoneAtIndex:indexPath];
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}


@end
