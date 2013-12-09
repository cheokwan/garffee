//
//  PhotoHuntViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "PhotoHuntViewController.h"

#import "TSTheming.h"

#define COUNT_DOWN_UPDATE_INTERVAL  0.01f

@interface PhotoHuntViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIAlertView *userEndGameAlertView, *loseAlertView, *winAlertView;
@property (nonatomic, strong) NSMutableArray *activeAlertViews;
@property (nonatomic) NSTimeInterval startTime;
@end

@implementation PhotoHuntViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _startTime = -1.0f;
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
    _startTime = [NSDate timeIntervalSinceReferenceDate];
    if (_timeLimit > 0.0f) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DOWN_UPDATE_INTERVAL target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
}

- (void)countDown {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    float progress = (_timeLimit - (now - _startTime)) / _timeLimit;
    if (progress <= 0.0f) {
        [_countDownSlider setValue:0.0f animated:YES];
        [self.timer invalidate];
        [self timesUp];
    } else {
        [_countDownSlider setValue:progress animated:YES];
    }
}

- (void)timesUp {
    NSLog(@"time's up!!");
    if (_userEndGameAlertView) {
        [_userEndGameAlertView dismissWithClickedButtonIndex:_userEndGameAlertView.cancelButtonIndex animated:NO];
        [self unregisterAlertView:_userEndGameAlertView];
        self.userEndGameAlertView.delegate = nil;
        self.userEndGameAlertView = nil;
    }
    self.loseAlertView = [[UIAlertView alloc] initWithTitle:LS_LOSE_GAME_TITLE message:LS_LOSE_GAME_DETAILS delegate:self cancelButtonTitle:LS_OK otherButtonTitles:nil];
    [_loseAlertView show];
    [self loseGame];
}

- (void)loseGame {
    //XXX-ML network call to server
}

- (void)winGame {
    self.winAlertView = [[UIAlertView alloc] initWithTitle:LS_CONGRATULATIONS message:LS_WIN_GAME_DETAILS delegate:self cancelButtonTitle:LS_OK otherButtonTitles:nil];
    [_winAlertView show];
    //XXX-ML network call to server
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:NO completion:nil];
    if ([_delegate respondsToSelector:@selector(photoHuntViewControllerDidFinishGame:)]) {
        [_delegate photoHuntViewControllerDidFinishGame:self];
    }
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
        if (buttonIndex == 1) {
            [_timer invalidate];
            self.timer = nil;
            [self loseGame];
            [self dismissSelf];
        }
    } else if (alertView == _loseAlertView) {
        [self dismissSelf];
    } else if (alertView == _winAlertView) {
        [self dismissSelf];
    }
}

@end
