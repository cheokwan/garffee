//
//  BranchDetailsTableViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 16/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "BranchDetailsTableViewController.h"

#import <UIView+Helpers/UIView+Helpers.h>
#import "BranchDetailsImageCell.h"

#import "BranchLocationMapViewController.h"
#import "TSTheming.h"

typedef NS_ENUM(NSInteger, BranchDetailsRows) {
    BranchDetailsRowsImage = 0,
    BranchDetailsRowsBranchName,
    BranchDetailsRowsOpeningHours,
    BranchDetailsRowsPhoneNumber,
    BranchDetailsRowsAddress,
    BranchDetailsRowsCount
};

#define NORMAL_CELL_HEIGHT  25.0f
#define FONT_SIZE           13.0f


@interface BranchDetailsTableViewController ()
@property (nonatomic, strong) BranchDetailsImageCell *imagePrototypeCell;
@property (nonatomic, strong) UITableViewCell *normalPrototypeCell;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation BranchDetailsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_STORE_INFO];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)initialize {
    self.dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"hh:mma";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 0.0f;
    switch (indexPath.row) {
        case BranchDetailsRowsImage:
            height = [self imagePrototypeCell].frameSizeHeight;
            break;
        default:
            height = NORMAL_CELL_HEIGHT;
            break;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return BranchDetailsRowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *normalCellIdentifier = @"NormalCell";
    NSString *cellIdentifier;
    switch (indexPath.row) {
        case BranchDetailsRowsImage:
            cellIdentifier = NSStringFromClass(BranchDetailsImageCell.class);
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            break;
        default:
            cellIdentifier = normalCellIdentifier;
            cell = [tableView dequeueReusableCellWithIdentifier:normalCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:normalCellIdentifier];
            }
            cell.frameSizeHeight = NORMAL_CELL_HEIGHT;
            break;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"";
    cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    cell.detailTextLabel.text = @"";
    cell.detailTextLabel.textColor= cell.textLabel.textColor;
    switch (indexPath.row) {
        case BranchDetailsRowsImage: {
            BranchDetailsImageCell *aCell = (BranchDetailsImageCell*)cell;
            aCell.branchImageURL = [_branch URLForImage];
        }
            break;
        case BranchDetailsRowsBranchName:
            cell.textLabel.text = _branch.name;
            break;
        case BranchDetailsRowsOpeningHours:
            cell.textLabel.text = LS_BUSINESS_HOUR;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [_dateFormatter stringFromDate:_branch.openTime], [_dateFormatter stringFromDate:_branch.closeTime]];
            break;
        case BranchDetailsRowsPhoneNumber:
            cell.textLabel.text = LS_CONTACT_NUMBER;
            cell.detailTextLabel.text = _branch.phoneNumber;
            break;
        case BranchDetailsRowsAddress:
            cell.textLabel.text = LS_ADDRESS;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == BranchDetailsRowsAddress) {
        BranchLocationMapViewController *branchLocationMapVC = (BranchLocationMapViewController*)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(BranchLocationMapViewController.class)];
        branchLocationMapVC.branch = _branch;
        [self.navigationController pushViewController:branchLocationMapVC animated:YES];
    }
}

#pragma mark - Cells
- (BranchDetailsImageCell *)imagePrototypeCell {
    if (!_imagePrototypeCell) {
        self.imagePrototypeCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(BranchDetailsImageCell.class)];
    }
    return _imagePrototypeCell;
}

@end
