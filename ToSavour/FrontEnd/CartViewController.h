//
//  CartViewController.h
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartHeaderView.h"
#import "ItemPickerViewController.h"
#import "PickUpLocationViewController.h"
#import "OrderItemTableViewCell.h"
#import "RestManager.h"

@interface CartViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ItemPickerViewControllerDelegate, PickUpLocationViewControllerDelegate, RestManagerResponseHandler, OrderItemTableViewCellDelegate>

@property (nonatomic, strong)   IBOutlet UITableView *itemList;
@property (nonatomic, strong)   IBOutlet CartHeaderView *cartHeaderView;
@property (nonatomic, strong)   IBOutlet UIView *placeholderView;
@property (nonatomic, strong)   IBOutlet UIImageView *placeholderCartImageView;
@property (nonatomic, strong)   IBOutlet UILabel *placeholderDescriptionView;
@property (nonatomic, strong)   IBOutlet UIButton *placeholderOrderNowButton;

@property (nonatomic, strong)   UIButton *addOrderButton;
@property (nonatomic, strong)   UIButton *editCartButton;
@property (nonatomic, strong)   UIButton *clearAllButton;

@property (nonatomic, strong)   MOrderInfo *pendingOrder;
@property (nonatomic, readonly) NSArray *inCartItems;

@property (nonatomic, assign)   BOOL animateViewAppearing;

- (void)refreshCart:(BOOL)animated;
- (void)updateRecipient:(MUserInfo *)recipient;

@end
