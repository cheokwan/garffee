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

@interface CouponDetailsViewController ()
@property (nonatomic, strong)   OrderItemTableViewCell *couponItemPrototypeCell;
@property (nonatomic, readonly) NSArray *couponItems;
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
        // TODO: redeem action;
    } else if (sender == _dismissButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSArray *)couponItems {
    return [[self.coupon.items allObjects] sortedArrayUsingSelector:@selector(creationDate)];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
