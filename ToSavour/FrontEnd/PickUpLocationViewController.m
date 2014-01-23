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
#define MAX_ESTIMATED_TIME          99
#define MIN_ESTIMATED_TIME          1

@interface PickUpLocationViewController ()
//UI related
@property (nonatomic, strong) UIButton *finishButton;
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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_PICK_UP_LOCATION];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.finishButton];
    [self.navigationItem.leftBarButtonItem setTintColor:[TSTheming defaultAccentColor]];
    [self updateFinishButtonAnimated:NO];
    
    [self.view bringSubviewToFront:_recommendedTimeView];
    [self updateTimeLabel:DEFAULT_ESTIMATED_TIME animated:NO];
    _recommendedTimeView.backgroundColor = [TSTheming defaultBackgroundTransparentColor];
    _recommendedTimeConstantLabel.text = LS_RECOMMENDED_TIME;
    _recommendedTimeConstantLabel.textColor = [TSTheming defaultThemeColor];
    
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(PickUpLocationTableViewCell.class) bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass(PickUpLocationTableViewCell.class)];
    _tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, _recommendedTimeView.frame.size.height, 0.0);
}

- (void)initialize {
    self.selectedBranch = nil;
    self.estimatedTimeFromWeb = 0;
    self.userEstimateTime = 0;
}

- (IBAction)buttonPressed:(id)sender {
    if (sender == _finishButton) {
        [self.confirmOrderAlertView show];
    } else if (sender == _addTimeButton) {
        self.userEstimateTime = MIN(_userEstimateTime + 1, MAX_ESTIMATED_TIME);
        [self updateTimeLabel:_userEstimateTime animated:NO];
        _minusTimeButton.enabled = YES;
        if (_userEstimateTime == MAX_ESTIMATED_TIME) {
            _addTimeButton.enabled = NO;
        }
    } else if (sender == _minusTimeButton) {
        self.userEstimateTime = MAX(_userEstimateTime - 1, MIN_ESTIMATED_TIME);
        [self updateTimeLabel:_userEstimateTime animated:NO];
        _addTimeButton.enabled = YES;
        if (_userEstimateTime == MIN_ESTIMATED_TIME) {
            _minusTimeButton.enabled = NO;
        }
    }
}

- (void)updateTimeLabel:(int)minute animated:(BOOL)animated {
    NSString *timeText = [NSString stringWithFormat:@"%02d:00 mins", minute];
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            _timeLabel.alpha = 0.0;
            _timeLabel.text = timeText;
            _timeLabel.alpha = 1.0;
        }];
    } else {
        _timeLabel.text = timeText;
    }
}

- (UIButton *)finishButton {
    if (!_finishButton) {
        self.finishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_finishButton setTitle:LS_FINISH forState:UIControlStateNormal];
        [_finishButton setTintColor:[TSTheming defaultAccentColor]];
        [_finishButton setTitleColor:[TSTheming defaultAccentColor] forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor clearColor] forState:UIControlStateDisabled];
        [_finishButton sizeToFit];
        _finishButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, -5.0);
        [_finishButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

- (UIAlertView *)confirmOrderAlertView {
    if (!_confirmOrderAlertView) {
        RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:LS_CANCEL];
        RIButtonItem *confirmButton = [RIButtonItem itemWithLabel:LS_CONFIRM];
        [confirmButton setAction:^{
            //self.order.status = MOrderInfoStatusPending;  // don't need to change the status on client
            self.order.storeBranchID = _selectedBranch.branchId;
            self.order.orderedDate = [NSDate date];
            int userExpectedTimeInSecond = _userEstimateTime * 60;
            self.order.expectedArrivalTime = [self.order.orderedDate dateByAddingTimeInterval:userExpectedTimeInSecond];
            //self.order.pickupTime = [self.order.expectedArrivalTime copy];
            
            self.spinner = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _spinner.mode = MBProgressHUDModeIndeterminate;
            _spinner.labelText = LS_SUBMITTING;
            
            NSAssert([self.order.recipient isEqual:[MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext]], @"submitting order but recipient is not app user");
            [[RestManager sharedInstance] postOrder:self.order handler:self];
        }];
        
        self.confirmOrderAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Submit order now?", @"") message:nil cancelButtonItem:cancelButton otherButtonItems:confirmButton, nil];
    }
    return _confirmOrderAlertView;
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
    if (cell.branch != _selectedBranch) {
        [[TSBranchServiceCalls sharedInstance] fetchEstimatedTime:self branch:_selectedBranch];
    }
    
    self.selectedBranch = cell.branch;
    [self.tableView reloadData];
}

#pragma mark - fetch related
- (NSArray *)branches {
    return self.branchFRC.fetchedObjects;
}

- (NSFetchedResultsController *)branchFRC {
    if (!_branchFRC) {
        NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
        NSFetchRequest *fetchRequest = [MBranch fetchRequest];
        self.branchFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        // TODO: use fetched results controller delegate to handle branch changes
        
        NSError *error = nil;
        if (![_branchFRC performFetch:&error]) {
            DDLogError(@"error fetching branches: %@", error);
            _branchFRC = nil;
        }
    }
    return _branchFRC;
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
    [self updateFinishButtonAnimated:YES];
}

- (void)updateFinishButtonAnimated:(BOOL)animated {
    BOOL enabled = _selectedBranch != nil;
    if (animated && enabled != _finishButton.enabled) {
        [UIView animateWithDuration:0.2 animations:^{
            _finishButton.alpha = 0.0;
            _finishButton.enabled = enabled;
            _finishButton.alpha = 1.0;
        }];
    } else {
        _finishButton.enabled = enabled;
    }
}

#pragma mark - RestManagerResponseHandler
- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(fetchEstimatedTime:branch:)) {
        if (userInfo[@"EstimatedTime"]) {
            self.estimatedTimeFromWeb = [userInfo[@"EstimatedTime"] intValue];
            self.userEstimateTime = _estimatedTimeFromWeb;
            [self updateTimeLabel:_userEstimateTime animated:YES];
        }
    } else if (selector == @selector(postOrder:handler:)) {
        DDLogInfo(@"successfully submitted order to server");
        
        RIButtonItem *dismissButton = [RIButtonItem itemWithLabel:LS_OK];
        [dismissButton setAction:^{
            if ([_delegate respondsToSelector:@selector(pickUpLocationViewControllerDidSubmitOrderSuccessfully:)]) {
                [_delegate pickUpLocationViewControllerDidSubmitOrderSuccessfully:self];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [_spinner hide:YES];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your order has been submitted, thank you!", @"") message:nil cancelButtonItem:dismissButton otherButtonItems:nil, nil] show];
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(postOrder:handler:)) {
        DDLogWarn(@"error in submitting order to server: %@", error);
        
        RIButtonItem *dismissButton = [RIButtonItem itemWithLabel:LS_OK];
        [dismissButton setAction:^{
            if ([_delegate respondsToSelector:@selector(pickUpLocationViewControllerDidFailToSubmitOrder:)]) {
                [_delegate pickUpLocationViewControllerDidFailToSubmitOrder:self];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [_spinner hide:YES];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Order Submit Error", @"") message:NSLocalizedString(@"Your order has failed to submit, please try again later", @"") cancelButtonItem:dismissButton otherButtonItems:nil, nil] show];
    }
}

@end
