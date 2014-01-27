//
//  OrderItemTableViewCell.h
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MItemInfo.h"

@class OrderItemTableViewCell;

@protocol OrderItemTableViewCellDelegate <NSObject>
- (void)orderItemTableViewCell:(OrderItemTableViewCell *)cell didEditOrderItem:(MItemInfo *)item;
@end

@interface OrderItemTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, strong)   IBOutlet UIImageView *itemImageView;
@property (nonatomic, strong)   IBOutlet UILabel *itemNameLabel;
@property (nonatomic, strong)   IBOutlet UILabel *itemDetailsLabel;
@property (nonatomic, strong)   IBOutlet UILabel *quantityLabel;
@property (nonatomic, strong)   IBOutlet UILabel *priceLabel;
@property (nonatomic, strong)   IBOutlet UITextField *quantityTextField;

@property (nonatomic, strong)   UIToolbar *keyboardBar;
@property (nonatomic, strong)   UIBarButtonItem *keyboardDoneButton;
@property (nonatomic, weak)     id<OrderItemTableViewCellDelegate> delegate;

@property (nonatomic, strong)   MItemInfo *item;

- (void)configureWithItem:(MItemInfo *)item;

@end
