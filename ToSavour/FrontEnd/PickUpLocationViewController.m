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
#import <MBProgressHUD/MBProgressHUD.h>
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>

#define DEFAULT_ESTIMATED_TIME      5

@interface PickUpLocationViewController ()
//UI related
@property (nonatomic, strong) UIBarButtonItem *finishButton;
@property (nonatomic, strong) UIAlertView *confirmOrderAlertView;
@property (nonatomic, strong) PickUpLocationTableViewCell *prototypeCell;
@property (nonatomic, strong) MBProgressHUD *spinner;

//logic
@property (nonatomic, strong) MBranch *selectedBranch;
@end

@implementation PickUpLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
	// Do any additional setup after loading the view.
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_PICK_UP_LOCATION];
    self.finishButton = [[UIBarButtonItem alloc] initWithTitle:LS_FINISH style:UIBarButtonItemStylePlain target:self action:@selector(buttonPressed:)];
    _finishButton.tintColor = [TSTheming defaultAccentColor];
    [self.navigationItem setRightBarButtonItem:_finishButton];
    [self updateFinishButton];
    [self.navigationItem.leftBarButtonItem setTintColor:[TSTheming defaultAccentColor]];
    [self.view bringSubviewToFront:_recommendedTimeView];
    [self updateTimeLabel:DEFAULT_ESTIMATED_TIME];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(PickUpLocationTableViewCell.class) bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass(PickUpLocationTableViewCell.class)];
}

- (void)initialize {
    self.selectedBranch = nil;
    self.estimatedTimeFromWeb = 0;
    self.userEstimateTime = 0;
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
    [cell configureWithBranch:branch];
    UIImage *accessoryImage;
    if (cell.branch == self.selectedBranch) {
        accessoryImage = [UIImage imageNamed:@"ico_select"];
    } else {
        accessoryImage = [UIImage imageNamed:@"ico_unselect"];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:accessoryImage];
    imageView.frame = CGRectMake(0, 0, 25, 25);
    cell.accessoryView = imageView;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    NSFetchRequest *fetchRequest = [MBranch fetchRequest];
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
    } else if (selector == @selector(postOrder:handler:) ||
               selector == @selector(postGiftCoupon:handler:)) {
        DDLogInfo(@"successfully submitted order to server");
        
        RIButtonItem *dismissButton = [RIButtonItem itemWithLabel:LS_OK];
        [dismissButton setAction:^{
            if ([_delegate respondsToSelector:@selector(pickUpLocationViewControllerDidSubmitOrderSuccessfully:)]) {
                [_delegate pickUpLocationViewControllerDidSubmitOrderSuccessfully:self];
            }
            [_spinner hide:NO];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Order has been submitted, thank you!", @"") cancelButtonItem:dismissButton otherButtonItems:nil, nil] show];
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(postOrder:handler:) ||
        selector == @selector(postGiftCoupon:handler:)) {
        DDLogWarn(@"error in submitting order to server: %@", error);
        
        RIButtonItem *dismissButton = [RIButtonItem itemWithLabel:LS_OK];
        [dismissButton setAction:^{
            if ([_delegate respondsToSelector:@selector(pickUpLocationViewControllerDidFailToSubmitOrder:)]) {
                [_delegate pickUpLocationViewControllerDidFailToSubmitOrder:self];
            }
            [_spinner hide:NO];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Order Submit Error", @"") message:NSLocalizedString(@"Order submission failed, please try again later", @"") cancelButtonItem:dismissButton otherButtonItems:nil, nil] show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _confirmOrderAlertView) {
        self.confirmOrderAlertView.delegate = nil;
        self.confirmOrderAlertView = nil;
        if (buttonIndex != alertView.cancelButtonIndex) {
//            self.order.status = MOrderInfoStatusPending;  // don't need to change the status on client
            self.order.storeBranchID = _selectedBranch.branchId;
            self.order.orderedDate = [NSDate date];
            int userExpectedTimeInSecond = _userEstimateTime * 60;
            self.order.expectedArrivalTime = [self.order.orderedDate dateByAddingTimeInterval:userExpectedTimeInSecond];
            self.order.pickupTime = [self.order.expectedArrivalTime copy];
            
            self.spinner = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _spinner.mode = MBProgressHUDModeIndeterminate;
            _spinner.labelText = LS_SUBMITTING;
            
            if ([self.order.recipient isEqual:[MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext]]) {
                [[RestManager sharedInstance] postOrder:self.order handler:self];
            } else {
                [[RestManager sharedInstance] postGiftCoupon:self.order handler:self];
            }
        }
    }
}

@end
