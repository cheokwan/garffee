//
//  BranchListViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 11/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "BranchListViewController.h"
#import "BranchLocationMapViewController.h"
#import "TSTheming.h"

@implementation BranchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
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
    cell.dateFormatter = self.dateFormatter;
    [cell configureWithBranch:branch];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BranchLocationMapViewController *branchLocationMapVC = (BranchLocationMapViewController*)[TSTheming viewControllerWithStoryboardIdentifier:@"BranchLocationMapViewController" storyboard:@"Main"];
    MBranch *branch = self.branches[indexPath.row];
    branchLocationMapVC.branch = self.branches[indexPath.row];
    [self.navigationController pushViewController:branchLocationMapVC animated:YES];
}

@end

