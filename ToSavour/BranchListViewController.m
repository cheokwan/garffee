//
//  BranchListViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 11/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "BranchListViewController.h"
#import "BranchDetailsTableViewController.h"
#import "TSTheming.h"

@implementation BranchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeView];
}

- (void)initializeView {
    self.navigationItem.rightBarButtonItem = nil;
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(PickUpLocationTableViewCell.class) bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass(PickUpLocationTableViewCell.class)];
}

#pragma mark - UITableView related

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PickUpLocationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(PickUpLocationTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(PickUpLocationTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    MBranch *branch = self.branches[indexPath.row];
    [cell configureWithBranch:branch];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BranchDetailsTableViewController *branchDetailsTableVC = (BranchDetailsTableViewController*)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(BranchDetailsTableViewController.class)];
    [branchDetailsTableVC initialize];
    branchDetailsTableVC.branch = self.branches[indexPath.row];
    [self.navigationController pushViewController:branchDetailsTableVC animated:YES];
}

@end


