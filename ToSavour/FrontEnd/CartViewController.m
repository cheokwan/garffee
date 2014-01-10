//
//  CartViewController.m
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "CartViewController.h"
#import "TSFrontEndIncludes.h"
#import "CartItemTableViewCell.h"
#import "AppDelegate.h"
#import "TSNavigationController.h"
#import "MProductInfo.h"
#import "MItemInfo.h"
#import "MOrderInfo.h"

typedef enum {
    CartSectionItems = 0,
    CartSectionPromotion,
    CartSectionTotal,
} CartSection;

@interface CartViewController ()
@property (nonatomic, strong)   CartItemTableViewCell *cartItemPrototypeCell;
@end

@implementation CartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeView {
    _itemList.delegate = self;
    _itemList.dataSource = self;
    CartHeaderView *cartHeader = (CartHeaderView *)[TSTheming viewWithNibName:NSStringFromClass(CartHeaderView.class) owner:self];
    cartHeader.frame = self.cartHeaderView.frame;
    self.cartHeaderView = cartHeader;
    [_cartHeaderView.checkoutButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cartHeaderView];
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_CART];
    self.navigationItem.leftBarButtonItem = self.addOrderButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshCart:NO];
}

- (MOrderInfo *)pendingOrder {
    if (!_pendingOrder) {
        self.pendingOrder = [MOrderInfo existingOrNewOrderInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    }
    return _pendingOrder;
}

- (NSArray *)inCartItems {
    return [[self.pendingOrder.items allObjects] sortedArrayUsingSelector:@selector(creationDate)];
}

- (UIBarButtonItem *)addOrderButton {
    if (!_addOrderButton) {
        self.addOrderButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonPressed:)];
        _addOrderButton.tintColor = [TSTheming defaultAccentColor];
    }
    return _addOrderButton;
}

- (void)buttonPressed:(id)sender {
    if (sender == _addOrderButton) {
        ItemPickerViewController *itemPicker = (ItemPickerViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(ItemPickerViewController.class)];
        itemPicker.delegate = self;
        TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:itemPicker];
        [self presentViewController:naviController animated:YES completion:nil];
    } else if (sender == _cartHeaderView.checkoutButton) {
        self.pendingOrder.userID = self.recipient.appID;
        self.pendingOrder.price = @(self.cartPrice);
        self.pendingOrder.orderedDate = [NSDate date];
        self.pendingOrder.expectedArrivalTime = [NSDate dateWithTimeIntervalSinceNow:300]; // XXXXX
        self.pendingOrder.pickupTime = [NSDate dateWithTimeIntervalSinceNow:300];  // XXXXX
        
        // TODO: cache this
        PickUpLocationViewController *pickUpLocationViewController = (PickUpLocationViewController*)[TSTheming viewControllerWithStoryboardIdentifier:@"PickUpLocationViewController"];
        pickUpLocationViewController.delegate = self;
        pickUpLocationViewController.order = _pendingOrder;
        [self.navigationController pushViewController:pickUpLocationViewController animated:YES];
    }
}

- (void)refreshCart:(BOOL)animated {
    [_itemList reloadSections:[NSIndexSet indexSetWithIndex:CartSectionItems] withRowAnimation: animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
    if (![_cartHeaderView hasRecipient] && self.inCartItems.count > 0) {
        MUserInfo *appUser = [MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
        [_cartHeaderView updateRecipient:appUser];
        self.recipient = appUser;
    }
    CGFloat totalPrice = 0.0;
    for (MItemInfo *item in self.inCartItems) {
        totalPrice += [item.price floatValue];
    }
    [_cartHeaderView updateTotalPrice:totalPrice];
    self.cartPrice = totalPrice;
    _cartHeaderView.checkoutButton.enabled = self.inCartItems.count > 0;
}


#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return CartSectionTotal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case CartSectionItems:
            return self.inCartItems.count;
            break;
        case CartSectionPromotion:
            return 0;
            break;
    }
    return 0;
}

- (CartItemTableViewCell *)cartItemPrototypeCell {
    if (!_cartItemPrototypeCell) {
        self.cartItemPrototypeCell = [_itemList dequeueReusableCellWithIdentifier:NSStringFromClass(CartItemTableViewCell.class)];
    }
    return _cartItemPrototypeCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cartItemPrototypeCell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [_itemList dequeueReusableCellWithIdentifier:NSStringFromClass(CartItemTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CartSectionItems: {
            CartItemTableViewCell *cartItemCell = (CartItemTableViewCell *)cell;
            MItemInfo *itemInfo = self.inCartItems[indexPath.row];
            
            __weak CartItemTableViewCell *weakCartItemCell = cartItemCell;
            [cartItemCell.itemImageView setImageWithURL:[NSURL URLWithString:itemInfo.product.resolvedImageURL] placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (image) {
                    weakCartItemCell.itemImageView.image = [image resizedImageToSize:weakCartItemCell.itemImageView.frame.size];
                } else {
                    DDLogWarn(@"cannot set image for cart item: %@ - error %@", weakCartItemCell.itemNameLabel.text, error);
                }
            }];
            
            cartItemCell.itemNameLabel.text = itemInfo.product.name;
            cartItemCell.itemDetailsLabel.text = itemInfo.description;  // TODO: fill in this detail
            cartItemCell.priceLabel.text = [NSString stringWithPrice:[itemInfo.price floatValue]];
            cartItemCell.quantityLabel.text = [NSString stringWithFormat:@"%@: %d", LS_QUANTITY, 1];  // TODO: handle quantity
        }
            break;
        case CartSectionPromotion: {
        }
            break;
    }
}

#pragma mark - ItemPickerViewControllerDelegate

- (void)itemPicker:(ItemPickerViewController *)itemPicker didAddItem:(MItemInfo *)item {
    [self.pendingOrder addItemsObject:item];
    [self.pendingOrder updatePrice];
    [self refreshCart:YES];
}

#pragma makr - PickUpLocationViewControllerDelegate

- (void)pickUpLocationViewControllerDidSubmitOrderSuccessfully:(PickUpLocationViewController *)viewController {
    [_pendingOrder deleteInContext:_pendingOrder.managedObjectContext];
    self.pendingOrder = nil;
    [[AppDelegate sharedAppDelegate].managedObjectContext save];
    [self refreshCart:YES];
}

- (void)pickUpLocationViewControllerDidFailToSubmitOrder:(PickUpLocationViewController *)viewController {
    _pendingOrder.status = MOrderInfoStatusInCart;  // revert status back to InCart
    [[AppDelegate sharedAppDelegate].managedObjectContext save];
}

@end
