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
#import <FacebookSDK/FacebookSDK.h>  // XXX-TEST
#import "MFriendInfo.h"  // XXX-TEST
#import "NSManagedObject+Helper.h" // XXX-TEST
#import "UIView+Helpers.h"
@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initializeView {
    UIBarButtonItem *rightSlideButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MenuIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(slideLeft)];
    self.navigationItem.rightBarButtonItem = rightSlideButton;
    self.navigationItem.titleView = [TSTheming navigationBrandNameTitleView];
}

- (void)slideLeft {
     static BOOL slided = NO;
     if (!slided) {
         [[AppDelegate sharedAppDelegate].slidingViewController anchorTopViewToLeftAnimated:YES];
     } else {
         [[AppDelegate sharedAppDelegate].slidingViewController resetTopViewAnimated:YES];
     }
     slided = !slided;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
    [self addPromotionButtons];
}

- (void)addPromotionButtons {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, _promotionScrollView.frameSizeWidth, _promotionScrollView.frameSizeHeight);
    button.backgroundColor = [UIColor greenColor];
    
    [_promotionScrollView addSubview:button];
    _promotionScrollView.contentSize = CGSizeMake(button.frameSizeWidth, button.frameSizeHeight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - buttonPressed
- (void)buttonPressed:(id)sender {
    //XXX-ML
    ChooseGameViewController *controller = (ChooseGameViewController*)[TSTheming viewControllerWithStoryboardIdentifier:@"ChooseGameViewController" storyboard:@"DailyGameStoryboard"];
    TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:naviController animated:YES completion:nil];
}

@end
