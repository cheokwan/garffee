//
//  CartViewController.m
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "CartViewController.h"
#import "TSFrontEndIncludes.h"
#import "OrderItemTableViewCell.h"
#import "AppDelegate.h"
#import "TSNavigationController.h"
#import "MProductInfo.h"
#import "MItemInfo.h"
#import "MOrderInfo.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "MainTabBarController.h"

typedef enum {
    CartSectionItems = 0,
    CartSectionPromotion,
    CartSectionTotal,
} CartSection;

@interface CartViewController ()
@property (nonatomic, strong)   OrderItemTableViewCell *cartItemPrototypeCell;
@property (nonatomic, strong)   UIAlertView *confirmGiftAlertView;
@property (nonatomic, strong)   MBProgressHUD *spinner;
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
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(OrderItemTableViewCell.class) bundle:[NSBundle mainBundle]];
    [_itemList registerNib:nib forCellReuseIdentifier:NSStringFromClass(OrderItemTableViewCell.class)];
    _itemList.contentInset = UIEdgeInsetsMake(_cartHeaderView.frame.size.height, 0.0, 0.0, 0.0);
    
    CartHeaderView *cartHeader = (CartHeaderView *)[TSTheming viewWithNibName:NSStringFromClass(CartHeaderView.class) owner:self];
    cartHeader.frame = self.cartHeaderView.frame;
    self.cartHeaderView = cartHeader;
    [_cartHeaderView.checkoutButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cartHeaderView];
    [_cartHeaderView.removeRecipientButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
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
    // TODO: reverse sort order
    return [[self.pendingOrder.items allObjects] sortedArrayUsingSelector:@selector(creationDate)];
}

- (UIBarButtonItem *)addOrderButton {
    if (!_addOrderButton) {
        self.addOrderButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonPressed:)];
        _addOrderButton.tintColor = [TSTheming defaultAccentColor];
    }
    return _addOrderButton;
}

- (UIAlertView *)confirmGiftAlertView {
    if (!_confirmGiftAlertView) {
        RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:LS_CANCEL];
        RIButtonItem *confirmButton = [RIButtonItem itemWithLabel:LS_CONFIRM];
        [confirmButton setAction:^{
            self.pendingOrder.orderedDate = [NSDate date];
            
            self.spinner = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _spinner.mode = MBProgressHUDModeIndeterminate;
            _spinner.labelText = LS_SUBMITTING;
            
            NSAssert(![self.pendingOrder.recipient isEqual:[MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext]], @"submitting gift coupon but recipient is app user");
            [[RestManager sharedInstance] postGiftCoupon:self.pendingOrder handler:self];
        }];
        
        self.confirmGiftAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Send gift to %@ now?", @""), self.pendingOrder.recipient.name] message:nil cancelButtonItem:cancelButton otherButtonItems:confirmButton, nil];
    }
    return _confirmGiftAlertView;
}

- (void)buttonPressed:(id)sender {
    if (sender == _addOrderButton) {
        ItemPickerViewController *itemPicker = (ItemPickerViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(ItemPickerViewController.class)];
        itemPicker.delegate = self;
        TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:itemPicker];
        [self presentViewController:naviController animated:YES completion:nil];
    } else if (sender == _cartHeaderView.checkoutButton) {
        if ([self.pendingOrder.recipient isEqual:[MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext]]) {
            // if recipient is app user himself, show store location picker
            PickUpLocationViewController *pickUpLocationViewController = (PickUpLocationViewController*)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(PickUpLocationViewController.class)];
            pickUpLocationViewController.delegate = self;
            pickUpLocationViewController.order = self.pendingOrder;
            [self.navigationController pushViewController:pickUpLocationViewController animated:YES];
        } else {
            // if recipient is a friend, confirm right away
            [self.confirmGiftAlertView show];
        }
    } else if (sender == _cartHeaderView.removeRecipientButton) {
        [UIView animateWithDuration:0.2 animations:^{
            _cartHeaderView.recipientAvatarView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self updateRecipient:nil];
            [UIView animateWithDuration:0.2 animations:^{
                _cartHeaderView.recipientAvatarView.alpha = 1.0;
            }];
        }];
    }
}

- (void)refreshCart:(BOOL)animated {
    [_itemList reloadSections:[NSIndexSet indexSetWithIndex:CartSectionItems] withRowAnimation: animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
    
    [self.pendingOrder updatePrice];
    [_cartHeaderView updateTotalPrice:[self.pendingOrder.price floatValue]];
    
    [_cartHeaderView updateRecipient:self.pendingOrder.recipient];
    
    _cartHeaderView.checkoutButton.enabled = self.inCartItems.count > 0 && self.pendingOrder.recipient;
    
    // update cart tab badge
    [[AppDelegate sharedAppDelegate].mainTabBarController updateCartTabBadge:self.tabBarItem];
}

- (void)updateRecipient:(MUserInfo *)recipient {
    [self.pendingOrder updateRecipient:recipient];
    [self refreshCart:NO];
}

- (void)clearPendingOrder {
    [_pendingOrder deleteInContext:_pendingOrder.managedObjectContext];
    self.pendingOrder = nil;
    [[AppDelegate sharedAppDelegate].managedObjectContext saveToPersistentStore];
    [self refreshCart:YES];
}

- (void)reinstatePendingOrder {
    _pendingOrder.status = MOrderInfoStatusInCart;  // revert status back to InCart
    [[AppDelegate sharedAppDelegate].managedObjectContext save];
}

#pragma makr - RestManagerResponseHandler

- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(postGiftCoupon:handler:)) {
        DDLogInfo(@"successfully submitted coupon to server");
        
        RIButtonItem *dismissButton = [RIButtonItem itemWithLabel:LS_OK];
        
        [_spinner hide:YES];
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Your gift has been sent to %@, thank you!", @""), self.pendingOrder.recipient.name] message:nil cancelButtonItem:dismissButton otherButtonItems:nil, nil] show];
        [self clearPendingOrder];
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(postGiftCoupon:handler:)) {
        DDLogWarn(@"error in submitting gift coupon to server: %@", error);
        
        RIButtonItem *dismissButton = [RIButtonItem itemWithLabel:LS_OK];
        
        [_spinner hide:YES];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Gift Sending Error", @"") message:@"Your gift order has failed to submit, please try again later" cancelButtonItem:dismissButton otherButtonItems:nil, nil] show];
        [self reinstatePendingOrder];
    }
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

- (OrderItemTableViewCell *)cartItemPrototypeCell {
    if (!_cartItemPrototypeCell) {
        self.cartItemPrototypeCell = [_itemList dequeueReusableCellWithIdentifier:NSStringFromClass(OrderItemTableViewCell.class)];
    }
    return _cartItemPrototypeCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cartItemPrototypeCell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [_itemList dequeueReusableCellWithIdentifier:NSStringFromClass(OrderItemTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CartSectionItems: {
            OrderItemTableViewCell *cartItemCell = (OrderItemTableViewCell *)cell;
            MItemInfo *itemInfo = self.inCartItems[indexPath.row];
            [cartItemCell configureWithItem:itemInfo];
        }
            break;
        case CartSectionPromotion: {
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ItemPickerViewControllerDelegate

- (void)itemPicker:(ItemPickerViewController *)itemPicker didAddItem:(MItemInfo *)item {
    [self.pendingOrder addItemsObject:item];
    [self.pendingOrder updatePrice];
    
    if (!self.pendingOrder.recipient) {
        MUserInfo *appUser = [MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
        [self.pendingOrder updateRecipient:appUser];
    }
    
    [self refreshCart:YES];
}

#pragma makr - PickUpLocationViewControllerDelegate

- (void)pickUpLocationViewControllerDidSubmitOrderSuccessfully:(PickUpLocationViewController *)viewController {
    [self clearPendingOrder];
}

- (void)pickUpLocationViewControllerDidFailToSubmitOrder:(PickUpLocationViewController *)viewController {
    [self reinstatePendingOrder];
}

@end
