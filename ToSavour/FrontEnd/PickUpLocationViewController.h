//
//  PickUpLocationViewController.h
//  ToSavour
//
//  Created by LAU Leung Yan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PickUpLocationTableViewCell.h"
#import "MOrderInfo.h"
#import "TSBranchServiceCalls.h"

@class PickUpLocationViewController;

@protocol PickUpLocationViewControllerDelegate <NSObject>
- (void)pickUpLocationViewControllerDidSubmitOrderSuccessfully:(PickUpLocationViewController *)viewController;
- (void)pickUpLocationViewControllerDidFailToSubmitOrder:(PickUpLocationViewController *)viewController;
@end

@interface PickUpLocationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PickUpLocationTableViewCellDelegate, RestManagerResponseHandler, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIView *recommendedTimeView;
@property (nonatomic, strong) IBOutlet UILabel *recommenedTimeConstantLabel;
@property (nonatomic, strong) IBOutlet UIButton *minusTimeButton;
@property (nonatomic, strong) IBOutlet UIButton *addTimeButton;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

//logic
@property (nonatomic) int estimatedTimeFromWeb;
@property (nonatomic) int userEstimateTime;

@property (nonatomic, strong) NSFetchedResultsController *branchFRC;

@property (nonatomic, strong) NSArray *branches;
@property (nonatomic, strong) MOrderInfo *order;

@property (nonatomic, weak) id<PickUpLocationViewControllerDelegate> delegate;

- (IBAction)buttonPressed:(id)sender;

- (void)initialize;

@end
