//
//  BranchDetailsImageCell.h
//  ToSavour
//
//  Created by LAU Leung Yan on 16/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BranchDetailsImageCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *branchImageView;
@property (nonatomic, strong) NSURL *branchImageURL;

@end
