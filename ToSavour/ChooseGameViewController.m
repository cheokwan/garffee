//
//  ChooseGameViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "ChooseGameViewController.h"
#import "TSTheming.h"
#import <AFNetworking.h>
#import <UIView+Helpers.h>

@interface ChooseGameViewController ()

@end

@implementation ChooseGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initializeView];
}

- (void)initializeView {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_DAILY_AWARD_GAME];
    
    _awardStrLabel.text = LS_AWARDS;
    NSUInteger awardNum = 1;
    _awardDetailsLabel.text = [NSString stringWithFormat:@"%@ X %d", LS_COFFEE, awardNum];
    _challengeNowStrLabel.text = LS_CHALLENGE_NOW;
    [self initializeScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)cancelButtonPressed:(id)sender {
    if ([_delegate respondsToSelector:@selector(chooseGameViewControllerWillDismiss:)]) {
        [_delegate chooseGameViewControllerWillDismiss:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - scroll view related
- (void)initializeScrollView {
    float width = 0.0f;
    for (int i=0; i<[self numberOfGames]; i++) {
        CGRect rect = CGRectMake(i*_gamesScrollView.frameSizeWidth, 0, _gamesScrollView.frameSizeWidth, _gamesScrollView.frameSizeHeight);
        UIImageView *anImageView = [[UIImageView alloc] initWithFrame:rect];
        [anImageView setImageWithURL:[NSURL URLWithString:@"http://1.bp.blogspot.com/-rU0MAHswsms/URx10AfQXvI/AAAAAAAAAQM/_Tq6WUIrBS0/s1600/Free-HD-Logo-Nike-Wallpaper.jpg"]];
        [_gamesScrollView addSubview:anImageView];
        width += _gamesScrollView.frameSizeWidth;
    }
    _gamesScrollView.contentSize = CGSizeMake(width, _gamesScrollView.frameSizeHeight);
    _gamesScrollView.showsHorizontalScrollIndicator = NO;
    _gamesScrollView.showsVerticalScrollIndicator = NO;
    _gamesScrollView.pagingEnabled = YES;
}

- (NSUInteger)numberOfGames {
    return 3;
}

@end
