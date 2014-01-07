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
#import "UIView+Helpers.h"
#import "FriendsListScrollView.h"
#import "MUserInfo.h"


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
    
    HomeControlView *controlView = (HomeControlView *)[TSTheming viewWithNibName:NSStringFromClass(HomeControlView.class) owner:self];
    controlView.frame = self.homeControlView.frame;
    self.homeControlView = controlView;
    [self.view addSubview:_homeControlView];
    [_homeControlView updateView];
    
    self.promotionScrollView.delegate = self;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
