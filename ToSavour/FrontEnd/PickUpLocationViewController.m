//
//  PickUpLocationViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "PickUpLocationViewController.h"

#import "NSManagedObject+Helper.h"

#import "TSTheming.h"
#import "MBranch.h"
#import "TSLocalizedString.h"
#import <UIView+Helpers/UIView+Helpers.h>

#define DEFAULT_ESTIMATED_TIME      5

@interface PickUpLocationViewController ()
//UI related
@property (nonatomic, strong) UIBarButtonItem *finishButton;
@property (nonatomic, strong) UIAlertView *confirmOrderAlertView;
@property (nonatomic, strong) PickUpLocationTableViewCell *prototypeCell;

//logic
@property (nonatomic, strong) NSFetchedResultsController *branchFRC;
@property (nonatomic, strong) MBranch *selectedBranch;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation PickUpLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_PICK_UP_LOCATION];
    self.finishButton = [[UIBarButtonItem alloc] initWithTitle:LS_FINISH style:UIBarButtonItemStylePlain target:self action:@selector(buttonPressed:)];
    _finishButton.tintColor = [TSTheming defaultAccentColor];
    [self.navigationItem setRightBarButtonItem:_finishButton];
    [self updateFinishButton];
    [self.view bringSubviewToFront:_recommendedTimeView];
    [self updateTimeLabel:DEFAULT_ESTIMATED_TIME];
}

- (void)initialize {
    self.selectedBranch = nil;
    self.estimatedTimeFromWeb = 0;
    self.userEstimateTime = 0;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"hh:mm";
    self.branchFRC = [self generateBranchFRC];
    NSError *error = nil;
    if (![_branchFRC performFetch:&error]) {
        DDLogDebug(@"fetch branch failed: %@", error);
    }
}

- (IBAction)buttonPressed:(id)sender {
    if (sender == _finishButton) {
        if (!_confirmOrderAlertView) {
            self.confirmOrderAlertView = [[UIAlertView alloc] initWithTitle:LS_CONFIRM_ORDER_TITLE message:LS_CONFIRM_ORDER_DETAILS delegate:self cancelButtonTitle:LS_CANCEL otherButtonTitles:LS_CONFIRM, nil];
            [_confirmOrderAlertView show];
        }
    } else if (sender == _addTimeButton) {
        self.userEstimateTime++;
        self.userEstimateTime = MIN(_userEstimateTime, 99);
        [self updateTimeLabel:_userEstimateTime];
    } else if (sender == _minusTimeButton) {
        self.userEstimateTime--;
        self.userEstimateTime = MAX(_userEstimateTime, 1);
        [self updateTimeLabel:_userEstimateTime];
    }
}

- (void)updateTimeLabel:(int)time {
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:00 mins", time];
}

#pragma mark - UITableView related
- (PickUpLocationTableViewCell *)prototypeCell {
    if (!_prototypeCell) {
        self.prototypeCell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass(PickUpLocationTableViewCell.class)];
    }
    return _prototypeCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.prototypeCell.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.branches.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PickUpLocationTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass(PickUpLocationTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(PickUpLocationTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    MBranch *branch = self.branches[indexPath.row];
    cell.dateFormatter = _dateFormatter;
    [cell configureWithBranch:branch];
    UIImage *accessoryImage;
    if (cell.branch == self.selectedBranch) {
        accessoryImage = [UIImage imageNamed:@"ico_select"];
    } else {
        accessoryImage = [UIImage imageNamed:@"ico_unselect"];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:accessoryImage];
    imageView.frame = CGRectMake(0, 0, 15, 15);
    cell.accessoryView = imageView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PickUpLocationTableViewCell *cell = (PickUpLocationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.selectedBranch = cell.branch;
    [self.tableView reloadData];
    //XXX-ML TO-DO: get estimated time
    [[TSBranchServiceCalls sharedInstance] fetchEstimatedTime:self branch:_selectedBranch];
}

#pragma mark - fetch related
- (NSArray *)branches {
    return _branchFRC.fetchedObjects;
}

- (NSFetchedResultsController *)generateBranchFRC {
    NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
    NSFetchRequest *fetchRequest = [MBranch fetchRequestInContext:context];
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    return resultsController;
}

#pragma mark - PickUpLocationTableViewCellDelegate
- (void)pickUpLocationTableViewCell:(PickUpLocationTableViewCell *)cell checkboxDidPress:(BOOL)isChecked {
    if (isChecked) {
        self.selectedBranch = cell.branch;
        [self.tableView reloadData];
        [[TSBranchServiceCalls sharedInstance] fetchEstimatedTime:self branch:_selectedBranch];
    }
}

- (void)setSelectedBranch:(MBranch *)selectedBranch {
    _selectedBranch = selectedBranch;
    [self updateFinishButton];
}

- (void)updateFinishButton {
    if (_selectedBranch) {
        _finishButton.enabled = YES;
    } else {
        _finishButton.enabled = NO;
    }
}

#pragma mark - RestManagerResponseHandler
- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(fetchEstimatedTime:branch:)) {
        if (userInfo[@"EstimatedTime"]) {
            self.estimatedTimeFromWeb = [userInfo[@"EstimatedTime"] intValue];
            self.userEstimateTime = _estimatedTimeFromWeb;
            [self updateTimeLabel:_userEstimateTime];
        }
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _confirmOrderAlertView) {
        self.confirmOrderAlertView.delegate = nil;
        self.confirmOrderAlertView = nil;
        if (buttonIndex != alertView.cancelButtonIndex) {
            self.order.storeBranchID = _selectedBranch.branchId;
            //XXX-ML proceed
            [[RestManager sharedInstance] postOrder:_order handler:nil];
        }
    }
}

@end
