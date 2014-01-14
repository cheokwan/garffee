//
//  OrderDetailsViewController.h
//  ToSavour
//
//  Created by Jason Wan on 14/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailsHeaderView.h"
#import "MOrderInfo.h"

@interface OrderDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)   IBOutlet OrderDetailsHeaderView *headerView;
@property (nonatomic, strong)   IBOutlet UITableView *orderDetailsList;
@property (nonatomic, strong)   UIBarButtonItem *dismissButton;

@property (nonatomic, strong)   MOrderInfo *order;


@end
