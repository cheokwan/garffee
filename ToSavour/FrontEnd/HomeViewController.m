//
//  HomeViewController.m
//  ToSavour
//
//  Created by Jason Wan on 5/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "HomeViewController.h"
#import "TSTheming.h"
#import "AppDelegate.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
