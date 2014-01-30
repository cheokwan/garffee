//
//  MainTabBarController.m
//  ToSavour
//
//  Created by Jason Wan on 5/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MainTabBarController.h"
#import "TSFrontEndIncludes.h"
#import <QuartzCore/QuartzCore.h>
#import "CartViewController.h"
#import "TSNavigationController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)initializeView {
    if ([self.tabBar respondsToSelector:@selector(setBarTintColor:)]) {
        [self.tabBar setBarTintColor:[TSTheming defaultContrastColor]];
        [self.tabBar setTintColor:[TSTheming defaultThemeColor]];
    } else {
        [self.tabBar setTintColor:[TSTheming defaultContrastColor]];
        [[UITabBar appearance] setSelectedImageTintColor:[TSTheming defaultAccentColor]];
    }
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 5.0f;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
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

- (void)awakeFromNib {
    [super awakeFromNib];
    for (int tabIndex = 0; tabIndex < self.tabBar.items.count; ++tabIndex) {
        UITabBarItem *item = self.tabBar.items[tabIndex];
        switch (tabIndex) {
            case MainTabBarControllerTabHome: {
                item.title = LS_HOME;
                [item setImage:[UIImage imageNamed:@"ico_home_off"]];
                [item setSelectedImage:[UIImage imageNamed:@"ico_home_on"]];
            }
                break;
            case MainTabBarControllerTabStore: {
                item.title = LS_STORE;
                [item setImage:[UIImage imageNamed:@"ico_store_off"]];
                [item setSelectedImage:[UIImage imageNamed:@"ico_store_on"]];
            }
                break;
            case MainTabBarControllerTabCart: {
                item.title = LS_CART;
                [item setImage:[UIImage imageNamed:@"ico_cart_off"]];
                [item setSelectedImage:[UIImage imageNamed:@"ico_cart_on"]];
            }
                break;
            case MainTabBarControllerTabFriends: {
                item.title = LS_FRIENDS;
                [item setImage:[UIImage imageNamed:@"ico_friends_off"]];
                [item setSelectedImage:[UIImage imageNamed:@"ico_friends_on"]];
            }
                break;
            case MainTabBarControllerTabAccount: {
                item.title = LS_ACCOUNT;
                [item setImage:[UIImage imageNamed:@"ico_account_off"]];
                [item setSelectedImage:[UIImage imageNamed:@"ico_account_on"]];
            }
                break;
            default: {
                NSAssert(NO, @"unexpected main tab bar index %d", tabIndex);
                DDLogError(@"unexpected main tab bar index %d", tabIndex);
            }
                break;
        }
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self updateCartTabBadge:item];
}

- (UIViewController *)viewControllerAtTab:(MainTabBarControllerTab)tab {
    UIViewController *viewController = nil;
    if (tab < self.viewControllers.count) {
        viewController = self.viewControllers[tab];
        if ([viewController isKindOfClass:UINavigationController.class]) {
            viewController = ((UINavigationController *)viewController).viewControllers[0];
        }
    }
    return viewController;
}

- (void)switchToTab:(MainTabBarControllerTab)tab animated:(BOOL)animated {
    if (tab < self.viewControllers.count) {
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                [self setSelectedIndex:tab];
            }];
        } else {
            [self setSelectedIndex:tab];
        }
    }
}

- (void)updateCartTabBadge:(UITabBarItem *)selectedItem {
//    NSUInteger index = [self.tabBar.items indexOfObject:selectedItem];
//    if (index != NSNotFound && index != MainTabBarControllerTabCart) {
// switching out from cart
    UINavigationController *navi = self.viewControllers[MainTabBarControllerTabCart];
    CartViewController *cart = navi.viewControllers[0];
    UITabBarItem *cartTabBarItem = [self.tabBar.items objectAtIndex:MainTabBarControllerTabCart];
    if (cart.inCartItems.count > 0) {
        [cartTabBarItem setBadgeValue:[@(cart.inCartItems.count) stringValue]];
    } else {
        [cartTabBarItem setBadgeValue:nil];
    }
//    } else if (index == MainTabBarControllerTabCart) {
//        UITabBarItem *cartTabBarItem = [self.tabBar.items objectAtIndex:MainTabBarControllerTabCart];
//        [cartTabBarItem setBadgeValue:nil];
//    }
}

@end
