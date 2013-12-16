//
//  TransactionHistoryTableViewCell.h
//  ToSavour
//
//  Created by Jason Wan on 14/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionHistoryTableViewCell : UITableViewCell

@property (nonatomic, strong)   IBOutlet UILabel *titleLabel;
@property (nonatomic, strong)   IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong)   IBOutlet UILabel *priceLabel;

@end
