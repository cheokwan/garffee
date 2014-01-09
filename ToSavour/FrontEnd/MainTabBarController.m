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

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)initializeView {
    if ([self.tabBar respondsToSelector:@selector(setBarTintColor:)]) {
        [self.tabBar setBarTintColor:[TSTheming defaultContrastColor]];
        [self.tabBar setTintColor:[TSTheming defaultAccentColor]];
        self.tabBar.alpha = 0.8; // XXX-TEST
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
    for (int tabIndex = 0; tabIndex < self.tabBar.items.count; ++tabIndex) {
        UITabBarItem *item = self.tabBar.items[tabIndex];
        switch (tabIndex) {
            case MainTabBarControllerTabHome: {
                item.title = LS_HOME;
            }
                break;
            case MainTabBarControllerTabStore: {
                item.title = LS_STORE;
            }
                break;
            case MainTabBarControllerTabCart: {
                item.title = LS_CART;
            }
                break;
            case MainTabBarControllerTabFriends: {
                item.title = LS_FRIENDS;
            }
                break;
            case MainTabBarControllerTabAccount: {
                item.title = LS_ACCOUNT;
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

@end
