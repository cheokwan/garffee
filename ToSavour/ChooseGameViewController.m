//
//  ChooseGameViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "ChooseGameViewController.h"

#import <AFNetworking.h>
#import <UIView+Helpers.h>
#import "TSNavigationController.h"
#import "TSTheming.h"

@interface ChooseGameViewController ()
@property (nonatomic, strong) NSMutableDictionary *buttonDict;
@end

@implementation ChooseGameViewController

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
    [_challengeNowButton setTitle:LS_CHALLENGE_NOW forState:UIControlStateNormal];
    [_challengeNowButton setTitle:LS_ALREADY_PLAYED forState:UIControlStateDisabled];
    [_challengeNowButton setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    [_challengeNowButton addTarget:self action:@selector(challengeNowButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self initializeScrollView];
    [self initializeCountDownView];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)gameUpdated {
    
}

#pragma mark - button pressed
- (void)cancelButtonPressed:(id)sender {
    if ([_delegate respondsToSelector:@selector(chooseGameViewControllerWillDismiss:)]) {
        [_delegate chooseGameViewControllerWillDismiss:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)challengeNowButtonPressed:(id)sender {
    _countDownView.hidden = NO;
    [self.view bringSubviewToFront:_countDownView];
    [self startCountDown];
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

- (int)currentPage {
    return (int)_gamesScrollView.contentOffset.x / self.view.frameSizeWidth;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self gameUpdated];
}

#pragma mark - count down view related
- (void)initializeCountDownView {
    _num1Button.userInteractionEnabled = NO;
    _num2Button.userInteractionEnabled = NO;
    _num3Button.userInteractionEnabled = NO;
    _num1Button.fillColor = [UIColor grayColor];
    _num2Button.fillColor = [UIColor grayColor];
    _num3Button.fillColor = [UIColor grayColor];
    [_num1Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_num2Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_num3Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.buttonDict = [NSMutableDictionary dictionary];
    _buttonDict[@(3)] = _num3Button;
    _buttonDict[@(2)] = _num2Button;
    _buttonDict[@(1)] = _num1Button;
    _countDownView.hidden = YES;
    _countDownView.userInteractionEnabled = NO;
}

- (void)startCountDown {
    [self countDown:@(0)];
    float interval = 0.5f;
    [self performSelector:@selector(countDown:) withObject:@(3) afterDelay:interval];
    interval += COUNT_DOWN_INTERVAL;
    [self performSelector:@selector(countDown:) withObject:@(2) afterDelay:interval];
    interval += COUNT_DOWN_INTERVAL;
    [self performSelector:@selector(countDown:) withObject:@(1) afterDelay:interval];
    interval += COUNT_DOWN_INTERVAL;
    [self performSelector:@selector(proceedFromCountDown) withObject:nil afterDelay:interval];
}

- (void)countDown:(NSNumber *)countStr {
    for (NSString *key in _buttonDict.allKeys) {
        if ([key intValue] == [countStr intValue]) {
            ((CountDownButton *)_buttonDict[key]).fillColor = [TSTheming defaultThemeColor];
            ((CountDownButton *)_buttonDict[key]).titleLabel.textColor = [UIColor whiteColor];
        } else {
            ((CountDownButton *)_buttonDict[key]).fillColor = [UIColor lightGrayColor];
            ((CountDownButton *)_buttonDict[key]).titleLabel.textColor = [UIColor whiteColor];
        }
        [(CountDownButton *)_buttonDict[key] setNeedsDisplay];
    }
}

- (NSUInteger)numberOfGames {
    return 3;
}

- (void)proceedFromCountDown {
    _countDownView.hidden = YES;
    [self.view sendSubviewToBack:_countDownView];
    [self countDown:@(0)];
    PhotoHuntViewController *photoHuntercontroller = [[PhotoHuntViewController alloc] initWithFilePackageName:@"AinoKishi01"];
    photoHuntercontroller.timeLimit = [self gameTimeLimit];
    photoHuntercontroller.timePenalty = [self gamePenalty];
    TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:photoHuntercontroller];
    photoHuntercontroller.delegate = self;
    [self presentViewController:naviController animated:NO completion:nil];
}

#pragma mark - PhotoHuntViewControllerDelegate / related
- (void)photoHuntViewControllerDidFinishGame:(PhotoHuntViewController *)controller {
    //XXX-ML
    NSLog(@"finished game and come back!");
}

- (float)gameTimeLimit {
    return 50.0f;
}

- (float)gamePenalty {
    return 3.0f;
}

@end
