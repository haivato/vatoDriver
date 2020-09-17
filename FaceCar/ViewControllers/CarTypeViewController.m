//
//  CarTypeViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/10/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "CarTypeViewController.h"
#import "CarTypeTableViewCell.h"

@interface CarTypeViewController ()

@end

@implementation CarTypeViewController

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listCarType.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CarTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CarTypeTableViewCell class]) forIndexPath:indexPath];
    
    [cell loadData:[self.listCarType objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    // delegate callback
    [self.delegate didChoosedCarType:[self.listCarType objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

@end
