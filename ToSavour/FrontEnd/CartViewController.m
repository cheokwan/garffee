//
//  CartViewController.m
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "CartViewController.h"
#import "TSFrontEndIncludes.h"
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

@property (nonatomic, strong)   UIAlertView *confirmClearAlertView;
@end

// TODO: control logic too complicated, need refactor

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.addOrderButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editCartButton];
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
    NSSortDescriptor *sdCreationDate = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES];
    return [self.pendingOrder.items sortedArrayUsingDescriptors:@[sdCreationDate]];
}

- (UIButton *)addOrderButton {
    if (!_addOrderButton) {
        self.addOrderButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_addOrderButton setImage:[UIImage imageNamed:@"ico_add"] forState:UIControlStateNormal];
        [_addOrderButton setTintColor:[TSTheming defaultAccentColor]];
        _addOrderButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, -5.0, 0.0, 5.0);
        [_addOrderButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addOrderButton;
}

- (UIButton *)editCartButton {
    if (!_editCartButton) {
        self.editCartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_editCartButton setImage:[UIImage imageNamed:@"ico_edit"] forState:UIControlStateNormal];
        [_editCartButton setImage:nil forState:UIControlStateDisabled];
        [_editCartButton setTintColor:[TSTheming defaultAccentColor]];
        _editCartButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, -5.0);
        [_editCartButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editCartButton;
}

- (UIButton *)clearAllButton {
    if (!_clearAllButton) {
        self.clearAllButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_clearAllButton setTitle:LS_CLEAR_ALL forState:UIControlStateNormal];
        [_clearAllButton setTitleColor:[TSTheming defaultAccentColor] forState:UIControlStateNormal];
        [_clearAllButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_clearAllButton sizeToFit];
        _clearAllButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, -5.0, 0.0, 5.0);
        [_clearAllButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearAllButton;
}

- (UIAlertView *)confirmGiftAlertView {
    if (!_confirmGiftAlertView) {
        RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:LS_CANCEL];
        [cancelButton setAction:^{
            self.confirmGiftAlertView = nil;
        }];
        
        RIButtonItem *confirmButton = [RIButtonItem itemWithLabel:LS_CONFIRM];
        [confirmButton setAction:^{
            self.pendingOrder.orderedDate = [NSDate date];
            
            self.spinner = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _spinner.mode = MBProgressHUDModeIndeterminate;
            _spinner.labelText = LS_SUBMITTING;
            
            NSAssert(![self.pendingOrder.recipient isEqual:[MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext]], @"submitting gift coupon but recipient is app user");
            [[RestManager sharedInstance] postGiftCoupon:self.pendingOrder handler:self];
            self.confirmGiftAlertView = nil;
        }];
        
        self.confirmGiftAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Send gift to %@ now?", @""), self.pendingOrder.recipient.name] message:nil cancelButtonItem:cancelButton otherButtonItems:confirmButton, nil];
    }
    return _confirmGiftAlertView;
}

- (UIAlertView *)confirmClearAlertView {
    if (!_confirmClearAlertView) {
        RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:LS_CANCEL];
        [cancelButton setAction:^{
            self.confirmClearAlertView = nil;
        }];
        
        RIButtonItem *confirmButton = [RIButtonItem itemWithLabel:LS_CONFIRM];
        [confirmButton setAction:^{
            NSArray *items = [self.pendingOrder.items allObjects];
            for (MItemInfo *item in items) {
                [self.pendingOrder removeItemsObject:item];
                [item deleteInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
            }
            [self refreshCart:YES];
            
            self.confirmClearAlertView = nil;
        }];
        
        self.confirmClearAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Clear cart now?", @"")] message:nil cancelButtonItem:cancelButton otherButtonItems:confirmButton, nil];
    }
    return _confirmClearAlertView;
}

- (void)buttonPressed:(id)sender {
    if (sender == _addOrderButton) {
        ItemPickerViewController *itemPicker = (ItemPickerViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(ItemPickerViewController.class)];
        itemPicker.delegate = self;
        itemPicker.defaultItem = [self.pendingOrder chosenItem];  // XXXXXX-TEST
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
            // restore to app user as the recipient
            [UIView animateWithDuration:0.3 animations:^{
                [self updateRecipient:[MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext]];
                _cartHeaderView.recipientAvatarView.alpha = 1.0;
            }];
        }];
    } else if (sender == _editCartButton) {
        BOOL editing = !_itemList.isEditing;
        [_itemList setEditing:editing animated:YES];
        [self refreshButtons:YES];
    } else if (sender == _clearAllButton) {
        [self.confirmClearAlertView show];
    }
}

- (void)refreshButtons:(BOOL)animated {
    // update add order button
    // TODO: too ugly, refactor these animated code
    if (_itemList.isEditing) {
        if (animated) {
            [_addOrderButton hideDisable:animated];
            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [_clearAllButton hideDisable:NO];
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.clearAllButton];
                [_clearAllButton unhideEnable:animated];
            });
        } else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.clearAllButton];
            [_clearAllButton unhideEnable:animated];
        }
    } else {
        if (animated) {
            [_clearAllButton hideDisable:animated];
            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [_addOrderButton hideDisable:NO];
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.addOrderButton];
                [_addOrderButton unhideEnable:animated];
            });
        } else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.addOrderButton];
            [_addOrderButton unhideEnable:animated];
        }
    }
    
    // update edit cart button
    if (animated) {
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.inCartItems.count > 0 ? [_editCartButton unhideEnable:animated] : [_editCartButton hideDisable:animated];
        });
    } else {
        self.inCartItems.count > 0 ? [_editCartButton unhideEnable:animated] : [_editCartButton hideDisable:animated];
    }
    
    // update checkout button
    _cartHeaderView.checkoutButton.enabled = self.inCartItems.count > 0 && self.pendingOrder.recipient && !_itemList.isEditing;
}

- (void)refreshPrice:(BOOL)animated {
    CGFloat beforePrice = [self.pendingOrder.price floatValue];
    [self.pendingOrder updatePrice];
    CGFloat afterPrice = [self.pendingOrder.price floatValue];
    if (beforePrice != afterPrice && animated) {
        [UIView animateWithDuration:0.2 animations:^{
            _cartHeaderView.priceLabel.alpha = 0.0;
            [_cartHeaderView updateTotalPrice:[self.pendingOrder.price floatValue]];
            _cartHeaderView.priceLabel.alpha = 1.0;
        }];
    } else {
        [_cartHeaderView updateTotalPrice:[self.pendingOrder.price floatValue]];
    }
}

- (void)refreshCart:(BOOL)animated {
    [self refreshPrice:animated];
    
    [_cartHeaderView updateRecipient:self.pendingOrder.recipient];
    
    if (_itemList.isEditing && self.inCartItems.count == 0) {
        [_itemList setEditing:NO animated:animated];
    }
    
    [self refreshButtons:animated];
    
    [_itemList reloadSections:[NSIndexSet indexSetWithIndex:CartSectionItems] withRowAnimation: animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
    
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
        [dismissButton setAction:^{
            [self clearPendingOrder];
            MainTabBarController *tabBarController = [AppDelegate sharedAppDelegate].mainTabBarController;
            [tabBarController switchToTab:MainTabBarControllerTabHome animated:YES];
        }];
        
        [_spinner hide:YES];
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Your gift has been sent to %@, thank you!", @""), self.pendingOrder.recipient.name] message:nil cancelButtonItem:dismissButton otherButtonItems:nil, nil] show];
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
            cartItemCell.delegate = self;
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CartSectionItems: {
            return YES;
        }
            break;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CartSectionItems: {
            return UITableViewCellEditingStyleDelete;
        }
            break;
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CartSectionItems: {
            return YES;
        }
            break;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CartSectionItems: {
            if (editingStyle == UITableViewCellEditingStyleDelete) {
                MItemInfo *itemToRemove = self.inCartItems[indexPath.row];
                
                [self.pendingOrder removeItemsObject:itemToRemove];
                [itemToRemove deleteInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
                
                [_itemList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
                [self refreshButtons:YES];
                [self refreshPrice:YES];
                double delayInSeconds = 0.3;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self refreshCart:NO];
                });
            }
        }
            break;
    }
}

//- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//}
//
//- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//}

#pragma mark - ItemPickerViewControllerDelegate

- (void)itemPicker:(ItemPickerViewController *)itemPicker didAddItem:(MItemInfo *)item {
    [self.pendingOrder addItemsObject:item];
    
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

#pragma mark - OrderItemTableViewCellDelegate

- (void)orderItemTableViewCell:(OrderItemTableViewCell *)cell didEditOrderItem:(MItemInfo *)item {
    [self refreshPrice:YES];
}

@end
