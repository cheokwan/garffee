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
#import "BranchDetailsNameCell.h"
#import "BranchDetailsNormalCell.h"
#import "BranchDetailsAddressCell.h"

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
@property (nonatomic, strong) BranchDetailsNameCell *namePrototypeCell;
@property (nonatomic, strong) BranchDetailsNormalCell *normalPrototypeCell;
@property (nonatomic, strong) BranchDetailsAddressCell *addressPrototypeCell;
@end

@implementation BranchDetailsTableViewController

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm" options:0 locale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:formatString];
    });
    return dateFormatter;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_STORE_INFO];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 0.0f;
    switch (indexPath.row) {
        case BranchDetailsRowsImage:
            height = [self imagePrototypeCell].frameSizeHeight;
            break;
        case BranchDetailsRowsBranchName:
            height = [self namePrototypeCell].frameSizeHeight;
            break;
        case BranchDetailsRowsOpeningHours:
        case BranchDetailsRowsPhoneNumber:
            height = [self normalPrototypeCell].frameSizeHeight;
            break;
        case BranchDetailsRowsAddress:
            height = [self addressPrototypeCell].frameSizeHeight;
            break;
        default:
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
    NSString *cellIdentifier;
    switch (indexPath.row) {
        case BranchDetailsRowsImage:
            cellIdentifier = NSStringFromClass(BranchDetailsImageCell.class);
            break;
        case BranchDetailsRowsBranchName:
            cellIdentifier = NSStringFromClass(BranchDetailsNameCell.class);
            break;
        case BranchDetailsRowsOpeningHours:
        case BranchDetailsRowsPhoneNumber:
            cellIdentifier = NSStringFromClass(BranchDetailsNormalCell.class);
            break;
        case BranchDetailsRowsAddress:
            cellIdentifier = NSStringFromClass(BranchDetailsAddressCell.class);
            break;
    }
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
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
    cell.detailTextLabel.textColor = cell.textLabel.textColor;
    switch (indexPath.row) {
        case BranchDetailsRowsImage: {
            BranchDetailsImageCell *aCell = (BranchDetailsImageCell*)cell;
            aCell.branchImageURL = [_branch URLForImage];
        }
            break;
        case BranchDetailsRowsBranchName: {
            BranchDetailsNameCell *aCell = (BranchDetailsNameCell*)cell;
            aCell.nameLabel.text = _branch.name;
            aCell.nameLabel.textColor = [TSTheming defaultThemeColor];
        }
            break;
        case BranchDetailsRowsOpeningHours: {
            BranchDetailsNormalCell *aCell = (BranchDetailsNormalCell*)cell;
            aCell.iconImageView.image = [UIImage imageNamed:@"ico_time"];
            aCell.detailsLabel.text = [NSString stringWithFormat:@"%@ - %@", [self.class.dateFormatter stringFromDate:_branch.openTime], [self.class.dateFormatter stringFromDate:_branch.closeTime]];
        }
            break;
        case BranchDetailsRowsPhoneNumber: {
            BranchDetailsNormalCell *aCell = (BranchDetailsNormalCell*)cell;
            aCell.iconImageView.image = [UIImage imageNamed:@"ico_phone"];
            aCell.detailsLabel.text = _branch.phoneNumber;
        }
            break;
        case BranchDetailsRowsAddress: {
            BranchDetailsAddressCell *aCell = (BranchDetailsAddressCell*)cell;
            aCell.iconImageView.image = [UIImage imageNamed:@"ico_location"];
            aCell.addressLabel.text = _branch.address;
            [aCell.addressLabel sizeToFit];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_pin"]];
            aCell.accessoryView = imageView;
        }
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

- (BranchDetailsNameCell *)namePrototypeCell {
    if (!_namePrototypeCell) {
        self.namePrototypeCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(BranchDetailsNameCell.class)];
    }
    return _namePrototypeCell;
}

- (BranchDetailsNormalCell *)normalPrototypeCell {
    if (!_normalPrototypeCell) {
        self.normalPrototypeCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(BranchDetailsNormalCell.class)];
    }
    return _normalPrototypeCell;
}

- (BranchDetailsAddressCell *)addressPrototypeCell {
    if (!_addressPrototypeCell) {
        self.addressPrototypeCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(BranchDetailsAddressCell.class)];
        float padding = _addressPrototypeCell.addressLabel.frameOriginY;
        _addressPrototypeCell.addressLabel.text = _branch.address;
        [_addressPrototypeCell.addressLabel sizeToFit];
        _addressPrototypeCell.frameSizeHeight = 2 * padding + _addressPrototypeCell.addressLabel.frameSizeHeight;
    }
    return _addressPrototypeCell;
}


@end
