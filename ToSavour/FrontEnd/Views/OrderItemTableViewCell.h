//
//  OrderItemTableViewCell.h
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MItemInfo.h"

@interface OrderItemTableViewCell : UITableViewCell

@property (nonatomic, strong)   IBOutlet UIImageView *itemImageView;
@property (nonatomic, strong)   IBOutlet UILabel *itemNameLabel;
@property (nonatomic, strong)   IBOutlet UILabel *itemDetailsLabel;
@property (nonatomic, strong)   IBOutlet UILabel *quantityLabel;
@property (nonatomic, strong)   IBOutlet UILabel *priceLabel;

- (void)configureWithItem:(MItemInfo *)item;

@end
