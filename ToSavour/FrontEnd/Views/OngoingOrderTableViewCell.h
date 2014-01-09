//
//  OngoingOrderTableViewCell.h
//  ToSavour
//
//  Created by Jason Wan on 8/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderProgressView.h"

@interface OngoingOrderTableViewCell : UITableViewCell

@property (nonatomic, strong)   IBOutlet UIImageView *itemImageView;
@property (nonatomic, strong)   IBOutlet UILabel *titleLabel;
@property (nonatomic, strong)   IBOutlet UILabel *priceLabel;
@property (nonatomic, strong)   IBOutlet UILabel *locationLabel;
@property (nonatomic, strong)   IBOutlet OrderProgressView *orderProgressView;

@end
