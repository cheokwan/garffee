//
//  CouponDetailsViewController.m
//  ToSavour
//
//  Created by Jason Wan on 10/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "CouponDetailsViewController.h"
#import "TSFrontEndIncludes.h"
#import "OrderItemTableViewCell.h"
#import "MItemInfo.h"
#import "CartViewController.h"
#import "HomeViewController.h"
#import "NSManagedObject+DeepCopying.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>

@interface CouponDetailsViewController ()
@property (nonatomic, strong)   OrderItemTableViewCell *couponItemPrototypeCell;
@property (nonatomic, readonly) NSArray *couponItems;
@property (nonatomic, strong)   UIAlertView *confirmClearCartAlertView;
@end

@implementation CouponDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)initializeView {
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_REDEEM_GIFT];
    self.navigationItem.rightBarButtonItem = self.dismissButton;
    
    CouponDetailsHeaderView *couponDetailsHeader = (CouponDetailsHeaderView *)[TSTheming viewWithNibName:NSStringFromClass(CouponDetailsHeaderView.class)];
    couponDetailsHeader.frame = self.headerView.frame;
    self.headerView = couponDetailsHeader;
    [self.view addSubview:_headerView];
    
    [_redeemButton setTitle:LS_REDEEM forState:UIControlStateNormal];
    _redeemButton.tintColor = [TSTheming defaultAccentColor];
    _redeemButton.backgroundColor = [TSTheming defaultThemeColor];
    _redeemButton.alpha = 0.85;
    [_redeemButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _couponItemsList.dataSource = self;
    _couponItemsList.delegate = self;
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(OrderItemTableViewCell.class) bundle:[NSBundle mainBundle]];
    [_couponItemsList registerNib:nib forCellReuseIdentifier:NSStringFromClass(OrderItemTableViewCell.class)];
    _couponItemsList.contentInset = UIEdgeInsetsMake(_headerView.frame.size.height, 0.0, _redeemButton.frame.size.height, 0.0);
    _couponItemsList.scrollIndicatorInsets = _couponItemsList.contentInset;
    [self.view bringSubviewToFront:_redeemButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (void)updateView {
    [_headerView updateReferenceNumber:_coupon.referenceCode];
    [_headerView updateSender:_coupon.sender];
    if ([_headerView.nameLabel.text trimmedWhiteSpaces].length == 0 &&
        _coupon.sponsorName) {
        _headerView.nameLabel.text = _coupon.sponsorName;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateView];
}

- (UIBarButtonItem *)dismissButton {
    if (!_dismissButton) {
        self.dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ico_close"] style:UIBarButtonItemStylePlain target:self action:@selector(buttonPressed:)];
        _dismissButton.tintColor = [TSTheming defaultAccentColor];
    }
    return _dismissButton;
}

- (void)buttonPressed:(id)sender {
    if (sender == _redeemButton) {
        MainTabBarController *tabBarController = [AppDelegate sharedAppDelegate].mainTabBarController;
        CartViewController *cart = (CartViewController *)[tabBarController viewControllerAtTab:MainTabBarControllerTabCart];
        if (cart.inCartItems.count > 0) {
            [[self confirmClearCartAlertView] show];
        } else {
            [self addCouponItemsToCart];
        }
    } else if (sender == _dismissButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSArray *)couponItems {
    return [[self.coupon.items allObjects] sortedArrayUsingSelector:@selector(creationDate)];
}

- (UIAlertView *)confirmClearCartAlertView {
    if (!_confirmClearCartAlertView) {
        RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:LS_CANCEL];
        [cancelButton setAction:^{
            self.confirmClearCartAlertView = nil;
        }];
        
        RIButtonItem *continueButton = [RIButtonItem itemWithLabel:LS_CLEAR];
        [continueButton setAction:^{
            [self addCouponItemsToCart];
            self.confirmClearCartAlertView = nil;
        }];
        
        self.confirmClearCartAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Adding these coupon items will clear the existing items in your cart, continue?", @"") message:nil cancelButtonItem:cancelButton otherButtonItems:continueButton, nil];
    }
    return _confirmClearCartAlertView;
}

- (void)addCouponItemsToCart {
    MainTabBarController *tabBarController = [AppDelegate sharedAppDelegate].mainTabBarController;
    CartViewController *cartViewController = (CartViewController *)[tabBarController viewControllerAtTab:MainTabBarControllerTabCart];
    
    for (MItemInfo *item in cartViewController.inCartItems) {
        [cartViewController.pendingOrder removeItemsObject:item];
        [item deleteInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    }
    
    NSArray *couponItems = [_coupon.items allObjects];
    for (MItemInfo *item in couponItems) {
        MItemInfo *itemCopy = [item deepCopyWithZone:nil];
        itemCopy.couponID = _coupon.id;
        itemCopy.coupon = nil;
        itemCopy.orderID = nil;
        itemCopy.order = nil;
        [cartViewController.pendingOrder addItemsObject:itemCopy];
    }
    
    HomeViewController *homeViewController = (HomeViewController *)[tabBarController viewControllerAtTab:MainTabBarControllerTabHome];
    [homeViewController.itemBagButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    MUserInfo *appUser = [MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    [cartViewController updateRecipient:appUser];
    cartViewController.animateViewAppearing = YES;
    [tabBarController switchToTab:MainTabBarControllerTabCart animated:NO];
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (OrderItemTableViewCell *)couponItemPrototypeCell {
    if (!_couponItemPrototypeCell) {
        self.couponItemPrototypeCell = [_couponItemsList dequeueReusableCellWithIdentifier:NSStringFromClass(OrderItemTableViewCell.class)];
    }
    return _couponItemPrototypeCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.couponItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.couponItemPrototypeCell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [_couponItemsList dequeueReusableCellWithIdentifier:NSStringFromClass(OrderItemTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    OrderItemTableViewCell *couponItemCell = (OrderItemTableViewCell *)cell;
    MItemInfo *itemInfo = self.couponItems[indexPath.row];
    [couponItemCell configureWithItem:itemInfo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
