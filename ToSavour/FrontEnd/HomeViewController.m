//
//  HomeViewController.m
//  ToSavour
//
//  Created by Jason Wan on 5/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "HomeViewController.h"
#import "TSNavigationController.h"
#import "TSFrontEndIncludes.h"
#import "AppDelegate.h"
#import "ChooseGameViewController.h"
#import "CartViewController.h"
#import "ItemPickerViewController.h"
#import "UIView+Helpers.h"
#import "FriendsListScrollView.h"
#import "MUserInfo.h"
#import "MOrderInfo.h"
#import "MCouponInfo.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import "NSManagedObject+DeepCopying.h"

@interface HomeViewController()
@property (nonatomic, strong)   UIAlertView *confirmClearCartAlertView;
@end

// TODO: fucking deadlock everywhere, figure out why

@implementation HomeViewController
@synthesize itemBagButton = _itemBagButton;
@synthesize itemBadgeView = _itemBadgeView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initializeView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.itemBagButton];
    self.navigationItem.titleView = [TSTheming navigationBrandNameTitleView];
    
    HomeControlView *controlView = (HomeControlView *)[TSTheming viewWithNibName:NSStringFromClass(HomeControlView.class) owner:self];
    controlView.frame = self.homeControlView.frame;
    self.homeControlView = controlView;
    [self.view addSubview:_homeControlView];
    [_homeControlView.orderNowButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.promotionScrollView.delegate = self;
}

- (UIButton *)itemBagButton {
    if (!_itemBagButton) {
        _itemBagButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_itemBagButton setImage:[UIImage imageNamed:@"ico_mybox"] forState:UIControlStateNormal];
        [_itemBagButton setTintColor:[TSTheming defaultAccentColor]];
        [_itemBagButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.itemBadgeView.badgeText = @"";
        [_itemBagButton addSubview:self.itemBadgeView];
    }
    return _itemBagButton;
}

- (TSBadgeView *)itemBadgeView {
    if (!_itemBadgeView) {
        _itemBadgeView = [[TSBadgeView alloc] init];
        _itemBadgeView.badgeAlignment = JSBadgeViewAlignmentTopRight;
        _itemBadgeView.badgeTextColor = [TSTheming defaultAccentColor];
        _itemBadgeView.badgeBackgroundColor = [TSTheming defaultBadgeBackgroundColor];
        _itemBadgeView.badgeStrokeColor = [TSTheming defaultBadgeBackgroundColor];
        _itemBadgeView.badgeStrokeWidth = 3.0;
        _itemBadgeView.badgePositionAdjustment = CGPointMake(-5.0, 8.0);
        _itemBadgeView.badgeTextFont = [UIFont systemFontOfSize:13.0];
        _itemBadgeView.userInteractionEnabled = NO;
    }
    return _itemBadgeView;
}

- (UIAlertView *)confirmClearCartAlertView {
    if (!_confirmClearCartAlertView) {
        RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:LS_CANCEL];
        [cancelButton setAction:^{
            self.confirmClearCartAlertView = nil;
        }];
        
        RIButtonItem *continueButton = [RIButtonItem itemWithLabel:LS_CONTINUE];
        [continueButton setAction:^{
            [self addLastOrderToCart];
            self.confirmClearCartAlertView = nil;
        }];
        
        self.confirmClearCartAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Adding these new items will clear the existing items in your cart, continue?"] message:nil cancelButtonItem:cancelButton otherButtonItems:continueButton, nil];
    }
    return _confirmClearCartAlertView;
}

- (void)addLastOrderToCart {
    MainTabBarController *tabBarController = [AppDelegate sharedAppDelegate].mainTabBarController;
    CartViewController *cart = (CartViewController *)[tabBarController viewControllerAtTab:MainTabBarControllerTabCart];
    NSAssert([cart isKindOfClass:CartViewController.class], @"getting cart from tab bar and it is not of class CartViewController");
    
    for (MItemInfo *item in cart.inCartItems) {
        [cart.pendingOrder removeItemsObject:item];
        [item deleteInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    }
    
    MOrderInfo *lastOrder = _homeControlView.cachedLastOrder;
    NSArray *lastOrderItems = [lastOrder.items allObjects];
    for (MItemInfo *item in lastOrderItems) {
        MItemInfo *itemCopy = [item deepCopyWithZone:nil];
        [cart.pendingOrder addItemsObject:itemCopy];
    }
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        MUserInfo *appUser = [MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
        [cart updateRecipient:appUser];
        cart.animateViewAppearing = YES;
        [tabBarController switchToTab:MainTabBarControllerTabCart animated:YES];
    });
}

- (void)updateItemBadgeCount {
    NSFetchRequest *frOngoingOrders = [MOrderInfo fetchRequest];
    frOngoingOrders.predicate = [NSPredicate predicateWithFormat:@"status IN[c] %@", @[MOrderInfoStatusPending, MOrderInfoStatusInProgress, MOrderInfoStatusFinished]];
    NSError *error = nil;
    NSUInteger countOngoingOrders = [[AppDelegate sharedAppDelegate].managedObjectContext countForFetchRequest:frOngoingOrders error:&error];
    if (error) {
        DDLogError(@"error counting ongoing orders: %@", error);
    }
    
    NSFetchRequest *frUnredeemedGifts = [MCouponInfo fetchRequest];
    MUserInfo *appUser = [MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    frUnredeemedGifts.predicate = [NSPredicate predicateWithFormat:@"receiverUserID = %@ AND (redeemedDate = %@ OR redeemedDate > %@)", appUser.appID, nil, [NSDate date]];
    error = nil;
    NSUInteger countUnredeemedGifts = [[AppDelegate sharedAppDelegate].managedObjectContext countForFetchRequest:frUnredeemedGifts error:&error];
    if (error) {
        DDLogError(@"error counting unredeemed gifts: %@", error);
    }
    
    NSString *countString = countOngoingOrders + countUnredeemedGifts > 0 ? [@(countOngoingOrders + countUnredeemedGifts) stringValue] : @"";
    self.itemBadgeView.badgeText = countString;
}

- (void)buttonPressed:(id)sender {
    if (sender == _itemBagButton) {
        static BOOL slided = NO;
        if (!slided) {
            [[AppDelegate sharedAppDelegate].slidingViewController anchorTopViewToLeftAnimated:YES];
        } else {
            [self updateItemBadgeCount];
            [[AppDelegate sharedAppDelegate].slidingViewController resetTopViewAnimated:YES];
        }
        slided = !slided;
    } else if (sender == _homeControlView.orderNowButton) {
        MainTabBarController *tabBarController = [AppDelegate sharedAppDelegate].mainTabBarController;
        CartViewController *cart = (CartViewController *)[tabBarController viewControllerAtTab:MainTabBarControllerTabCart];
        NSAssert([cart isKindOfClass:CartViewController.class], @"getting cart from tab bar and it is not of class CartViewController");
        
        if (_homeControlView.cachedLastOrder) {
            // if there was a last order, add the items to cart
            if (cart.inCartItems.count > 0) {
                [self.confirmClearCartAlertView show];
            } else {
                [self addLastOrderToCart];
            }
        } else {
            // if there was no last order, order now
            MUserInfo *appUser = [MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
            [cart updateRecipient:appUser];
            ItemPickerViewController *itemPicker = (ItemPickerViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(ItemPickerViewController.class)];
            itemPicker.delegate = cart;
            TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:itemPicker];
            [self presentViewController:naviController animated:YES completion:nil];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[AppDelegate sharedAppDelegate].mainTabBarController updateCartTabBadge:self.tabBarItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateItemBadgeCount];
    [_homeControlView updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PromotionScrollViewDelegate

- (void)promotionScrollView:(PromotionScrollView *)scrollView didSelectPromotionAtIndex:(NSInteger)index {
    ChooseGameViewController *controller = (ChooseGameViewController*)[TSTheming viewControllerWithStoryboardIdentifier:@"ChooseGameViewController" storyboard:@"DailyGameStoryboard"];
    TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:naviController animated:YES completion:nil];
}

@end
