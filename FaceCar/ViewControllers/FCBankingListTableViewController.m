//
//  FCBankingListTableViewController.m
//  FC
//
//  Created by tony on 9/2/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBankingListTableViewController.h"
#import "FCBankingTableViewCell.h"

#define CELL @"FCBankingTableViewCell"

@interface FCBankingListTableViewController ()
@property (strong, nonatomic) NSMutableArray* listBanking;
@end

@implementation FCBankingListTableViewController

- (id) init {
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Chọn ngân hàng";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackClick)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.listBanking = [[NSMutableArray alloc] init];
    NSArray* list = [FirebaseHelper shareInstance].appConfigure.banking;
    for (FCBanking* bank in list) {
        if (bank.active) {
            [self.listBanking addObject:bank];
        }
    }
    [self.tableView registerNib:[UINib nibWithNibName:CELL bundle:nil] forCellReuseIdentifier:CELL];
    [self.tableView reloadData];
}

- (void) onBackClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listBanking.count;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    FCBanking* bank = [self.listBanking objectAtIndex:indexPath.row];
    if (bank.id == _currentBank.id) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCBankingTableViewCell* cell = (FCBankingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL forIndexPath:indexPath];
    FCBanking* bank = ((FCBanking*)[self.listBanking objectAtIndex:indexPath.row]);
    cell.lblName.text = bank.name;
    cell.lblShortName.text = bank.shortName;
    [cell.icon setImageWithURL:[NSURL URLWithString:bank.icon] placeholderImage:[UIImage imageNamed:@"bank"]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    self.bankingSelected = [self.listBanking objectAtIndex:indexPath.row];
    [self onBackClick];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

@end
