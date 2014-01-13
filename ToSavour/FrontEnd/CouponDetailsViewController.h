//
//  CouponDetailsViewController.h
//  ToSavour
//
//  Created by Jason Wan on 10/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouponDetailsHeaderView.h"
#import "MCouponInfo.h"

@interface CouponDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)   IBOutlet CouponDetailsHeaderView *headerView;
@property (nonatomic, strong)   IBOutlet UITableView *couponItemsList;
@property (nonatomic, strong)   IBOutlet UIButton *redeemButton;
@property (nonatomic, strong)   UIBarButtonItem *dismissButton;
@property (nonatomic, strong)   MCouponInfo *coupon;

@end
