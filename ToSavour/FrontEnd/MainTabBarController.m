//
//  MainTabBarController.m
//  ToSavour
//
//  Created by Jason Wan on 5/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MainTabBarController.h"
#import "TSFrontEndIncludes.h"

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

@end
