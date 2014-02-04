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
        _itemBadgeView.badgeBackgroundColor = [TSTheming defaultThemeColor];
        _itemBadgeView.badgeStrokeColor = [TSTheming defaultThemeColor];
        _itemBadgeView.badgeStrokeWidth = 4.0;
        _itemBadgeView.badgePositionAdjustment = CGPointMake(-5.0, 8.0);
        _itemBadgeView.userInteractionEnabled = NO;
    }
    return _itemBadgeView;
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
        MUserInfo *appUser = [MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
        if ([cart isKindOfClass:CartViewController.class]) {
            [cart updateRecipient:appUser];
        }
        
        ItemPickerViewController *itemPicker = (ItemPickerViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(ItemPickerViewController.class)];
        itemPicker.delegate = cart;
        TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:itemPicker];
        
        // XXXXXX TESTING
        NSFetchRequest *fetchRequest = [MOrderInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"status = %@", MOrderInfoStatusInCart];
        NSError *error = nil;
        NSArray *orders = [[AppDelegate sharedAppDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            DDLogError(@"error fetching ongoing orders: %@", error);
        }
        if (orders.count > 0) {
            MOrderInfo *order = [orders firstObject];
            itemPicker.defaultItem = [order chosenItem];
        }
        // XXXXXX
        [self presentViewController:naviController animated:YES completion:nil];
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
