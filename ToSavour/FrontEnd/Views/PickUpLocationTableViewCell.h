//
//  PickUpLocationTableViewCell.h
//  ToSavour
//
//  Created by LAU Leung Yan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBranch.h"

@class PickUpLocationTableViewCell;
@protocol PickUpLocationTableViewCellDelegate <NSObject>
@end

@interface PickUpLocationTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *branchNameLabel, *openingHourLabel, *telephoneNumberLabel;
@property (nonatomic, strong) IBOutlet UIImageView *openingHourImageView, *telephoneNumberImageView;

@property (nonatomic, strong) MBranch *branch;
@property (nonatomic, assign) id<PickUpLocationTableViewCellDelegate> delegate;
@property (nonatomic, weak) NSDateFormatter *dateFormatter;

- (void)configureWithBranch:(MBranch *)branch;

@end
