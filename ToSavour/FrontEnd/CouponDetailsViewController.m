//
//  CouponDetailsViewController.m
//  ToSavour
//
//  Created by Jason Wan on 10/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "CouponDetailsViewController.h"
#import "TSFrontEndIncludes.h"
#import "CartItemTableViewCell.h"
#import "MItemInfo.h"
#import "MProductInfo.h"

@interface CouponDetailsViewController ()
@property (nonatomic, strong)   CartItemTableViewCell *couponItemPrototypeCell;
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
    
    CouponDetailsHeaderView *couponDetailsHeader = (CouponDetailsHeaderView *)[TSTheming viewWithNibName:NSStringFromClass(CouponDetailsHeaderView.class) owner:nil];
    couponDetailsHeader.frame = self.headerView.frame;
    self.headerView = couponDetailsHeader;
    [self.view addSubview:_headerView];
    
    [_redeemButton setTitle:LS_REDEEM forState:UIControlStateNormal];
    _redeemButton.tintColor = [TSTheming defaultAccentColor];
    _redeemButton.backgroundColor = [TSTheming defaultThemeColor];
    _redeemButton.alpha = 0.7;
    [_redeemButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _couponItemsList.dataSource = self;
    _couponItemsList.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (void)updateView {
    [_headerView updateReferenceNumber:_coupon.referenceCode];
    [_headerView updateSender:_coupon.issuer];
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

- (CartItemTableViewCell *)couponItemPrototypeCell {
    if (!_couponItemPrototypeCell) {
        self.couponItemPrototypeCell = [_couponItemsList dequeueReusableCellWithIdentifier:NSStringFromClass(CartItemTableViewCell.class)];
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
    cell = [_couponItemsList dequeueReusableCellWithIdentifier:NSStringFromClass(CartItemTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CartItemTableViewCell *couponItemCell = (CartItemTableViewCell *)cell;
    MItemInfo *itemInfo = self.couponItems[indexPath.row];
    
    __weak CartItemTableViewCell *weakCouponItemCell = couponItemCell;
    [couponItemCell.itemImageView setImageWithURL:[NSURL URLWithString:itemInfo.product.resolvedImageURL] placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            weakCouponItemCell.itemImageView.image = [image resizedImageToSize:weakCouponItemCell.itemImageView.frame.size];
        } else {
            DDLogWarn(@"cannot set image for coupon item: %@ - error %@", weakCouponItemCell.itemNameLabel.text, error);
        }
    }];
    
    couponItemCell.itemNameLabel.text = itemInfo.product.name;
    couponItemCell.itemDetailsLabel.text = itemInfo.description;  // TODO: fill in this detail
    couponItemCell.priceLabel.text = [NSString stringWithPrice:[itemInfo.price floatValue]];
    couponItemCell.quantityLabel.text = [NSString stringWithFormat:@"%@: %d", LS_QUANTITY, 1];  // TODO: handle quantity
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
