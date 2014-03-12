//
//  AccountInfoTableViewBalanceCell.h
//  ToSavour
//
//  Created by LAU Leung Yan on 26/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountInfoTableViewBalanceCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *grayBackgroundVew;
@property (nonatomic, strong) IBOutlet UILabel *balanceStringLabel;
@property (nonatomic, strong) IBOutlet UILabel *balance;

@end
