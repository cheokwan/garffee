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
    [self.view setBackgroundColor:[TSTheming defaultThemeColor]];
    if ([self.tabBar respondsToSelector:@selector(setBarTintColor:)]) {
        [self.tabBar setBarTintColor:[TSTheming defaultThemeColor]];
        [self.tabBar setTintColor:[TSTheming defaultAccentColor]];
    } else {
        [self.tabBar setTintColor:[TSTheming defaultThemeColor]];
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
