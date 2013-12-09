//
//  PhotoHuntViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "PhotoHuntViewController.h"

#import "TSTheming.h"

@interface PhotoHuntViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int timeLimitInt;
@property (nonatomic, strong) UIAlertView *userEndGameAlertView, *loseAlertView, *winAlertView;
@property (nonatomic, strong) NSMutableArray *activeAlertViews;
@end

@implementation PhotoHuntViewController

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
    UIBarButtonItem *endButton = [[UIBarButtonItem alloc] initWithTitle:LS_END style:UIBarButtonItemStylePlain target:self action:@selector(endButtonPressed:)];
    self.navigationItem.rightBarButtonItem = endButton;
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_DAILY_AWARD_GAME];
    _countDownSlider.userInteractionEnabled = NO;
    [_countDownSlider setValue:1.0f animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.delegate = nil;
    [_timer invalidate];
    self.timer = nil;
    self.userEndGameAlertView.delegate = nil;
    self.userEndGameAlertView = nil;
    self.loseAlertView.delegate = nil;
    self.loseAlertView = nil;
    self.winAlertView.delegate = nil;
    self.winAlertView = nil;
    self.activeAlertViews = nil;
}

- (void)startTimer {
    _timeLimitInt = (int)_timeLimit;
    if (_timeLimitInt > 0.0f) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
}

- (void)countDown {
    _timeLimitInt--;
    float progress = _timeLimitInt / _timeLimit;
    [_countDownSlider setValue:progress animated:YES];
    NSLog(@"countdown %d", _timeLimitInt);
    if (_timeLimitInt == 0) {
        [self.timer invalidate];
        [self timesUp];
    }
}

- (void)timesUp {
    NSLog(@"time's up!!");
}

#pragma mark - button pressed
- (void)endButtonPressed:(id)sender {
    self.userEndGameAlertView = [[UIAlertView alloc] initWithTitle:LS_END_GAME message:LS_END_GAME_DETAILS delegate:self cancelButtonTitle:LS_CANCEL otherButtonTitles:LS_END, nil];
    [_userEndGameAlertView show];
}

#pragma mark - UIAlertView related
- (void)registerAlertView:(UIAlertView *)alertView {
    [_activeAlertViews addObject:alertView];
}

- (void)unregisterAlertView:(UIAlertView *)alertView {
    [_activeAlertViews removeObject:alertView];
}

- (void)dismissAlertView:(UIAlertView *)alertView animated:(BOOL)animated {
    if ([_activeAlertViews containsObject:alertView]) {
        [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:animated];
        [self unregisterAlertView:alertView];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self unregisterAlertView:alertView];
    if (alertView == _userEndGameAlertView) {
        
    }
}

@end
