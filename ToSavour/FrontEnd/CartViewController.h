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
#import "RestManager.h"

@interface CartViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ItemPickerViewControllerDelegate, RestManagerResponseHandler, PickUpLocationViewControllerDelegate>

@property (nonatomic, strong)   IBOutlet UITableView *itemList;
@property (nonatomic, strong)   IBOutlet CartHeaderView *cartHeaderView;
@property (nonatomic, strong)   UIBarButtonItem *addOrderButton;

@property (nonatomic, strong)   MOrderInfo *pendingOrder;
@property (nonatomic, readonly) NSArray *inCartItems;

@property (nonatomic, strong)   MUserInfo *recipient;
@property (nonatomic, assign)   CGFloat cartPrice;

@end
