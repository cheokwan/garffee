//
//  AccountViewController.m
//  ToSavour
//
//  Created by Jason Wan on 13/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "AccountViewController.h"
#import "AccountInfoTableViewCell.h"
#import "TransactionHistoryTableViewCell.h"
#import "TSFrontEndIncludes.h"

@interface AccountViewController ()
@property (nonatomic, strong)   AccountInfoTableViewCell *accountInfoPrototypeCell;
@property (nonatomic, strong)   TransactionHistoryTableViewCell *transactionHistoryPrototypeCell;
@end

@implementation AccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initializeView {
    _infoTable.tableHeaderView = self.accountHeaderView;
    _infoTable.bounces = NO;
    _infoTable.delegate = self;
    _infoTable.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AccountHeaderView *)accountHeaderView {
    if (!_accountHeaderView) {
        self.accountHeaderView = (AccountHeaderView *)[TSTheming viewWithNibName:NSStringFromClass(AccountHeaderView.class)];
    }
    return _accountHeaderView;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.accountInfoPrototypeCell.frame.size.height;
}

- (AccountInfoTableViewCell *)accountInfoPrototypeCell {
    if (!_accountInfoPrototypeCell) {
        self.accountInfoPrototypeCell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(AccountInfoTableViewCell.class)];
    }
    return _accountInfoPrototypeCell;
}

- (TransactionHistoryTableViewCell *)transactionHistoryPrototypeCell {
    if (!_transactionHistoryPrototypeCell) {
        self.transactionHistoryPrototypeCell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(TransactionHistoryTableViewCell.class)];
    }
    return _transactionHistoryPrototypeCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(AccountInfoTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    AccountInfoTableViewCell *accountInfoCell = (AccountInfoTableViewCell *)cell;
    accountInfoCell.titleLabel.text = @"Fuck You";  // XXX-TEST
    return;
}

#pragma <#arguments#>

@end
