//
//  MainTabBarController.h
//  ToSavour
//
//  Created by Jason Wan on 5/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MainTabBarControllerTabHome = 0,
    MainTabBarControllerTabStore,
    MainTabBarControllerTabCart,
    MainTabBarControllerTabFriends,
    MainTabBarControllerTabAccount,
} MainTabBarControllerTab;

@interface MainTabBarController : UITabBarController

@end
