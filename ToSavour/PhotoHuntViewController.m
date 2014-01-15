//
//  PhotoHuntViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "PhotoHuntViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UIView+Helpers/UIView+Helpers.h>
#import "UIView+Helper.h"
#import "TSTheming.h"
#import "TSGameServiceCalls.h"

typedef enum {
    ImageViewENumNone           = 0,
    ImageViewENumUpperImage,
    ImageViewENumLowerImage
} ImageViewENum;

typedef enum {
    GameStateNotStarted         = 0,
    GameStateStarted,
    GameStateEnded
} GameState;

@interface PhotoHuntViewController ()
//views
@property (nonatomic, strong) UIAlertView *userEndGameAlertView, *loseAlertView, *winAlertView;
@property (nonatomic, strong) NSMutableArray *activeAlertViews;

//game logic
@property (nonatomic, strong) PhotoHuntManager *gameManager;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) float accumulativePenalty;
@property (nonatomic) GameState gameState;

@end

@implementation PhotoHuntViewController
- (id)initWithGameManager:(PhotoHuntManager *)gameManager {
    self = (PhotoHuntViewController *)[TSTheming viewControllerWithStoryboardIdentifier:@"PhotoHuntViewController" storyboard:@"DailyGameStoryboard"];
    if (self) {
        self.gameManager = gameManager;
        _gameManager.delegate = self;
    }
    return self;
}

- (void)initialize {
    _startTime = -1.0f;
    _accumulativePenalty = 0.0f;
    _gameState = GameStateNotStarted;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initialize];
    [self setupImageViews];
    
    UIBarButtonItem *endButton = [[UIBarButtonItem alloc] initWithTitle:LS_END style:UIBarButtonItemStylePlain target:self action:@selector(endButtonPressed:)];
    self.navigationItem.rightBarButtonItem = endButton;
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_DAILY_AWARD_GAME];
    _countDownSlider.userInteractionEnabled = NO;
    [_countDownSlider setValue:1.0f animated:NO];
    _sliderContainerView.backgroundColor = [UIColor lightGrayColor];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self setupImageViews];
    [self updateGridButtons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self positionViews];
    if (_gameState == GameStateNotStarted) {
        [self startGame];
    }
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
    self.gameManager = nil;
}

#pragma mark - game logic
- (void)startGame {
    [[TSGameServiceCalls sharedInstance] postGameStart:self game:_gameManager.game];
    _gameState = GameStateStarted;
    [self updateFoundChangesLabel];
    [self startTimer];
}

- (void)startTimer {
    _startTime = [NSDate timeIntervalSinceReferenceDate];
    if (!_timer && _gameManager.game.timeLimit > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DOWN_UPDATE_INTERVAL target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    }
}

- (void)countDown:(NSTimer *)timer {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    float timeLimit = (float)_gameManager.game.timeLimit;
    float progress = (timeLimit - (now - _startTime) - _accumulativePenalty) / timeLimit;
    if (progress <= 0.0f) {
        [_countDownSlider setValue:0.0f animated:YES];
        [self.timer invalidate];
        [self timesUp];
    } else {
        [_countDownSlider setValue:progress animated:YES];
    }
}

- (void)timesUp {
    DDLogInfo(@"time's up: %f", [NSDate timeIntervalSinceReferenceDate]);
    if (_userEndGameAlertView) {
        [_userEndGameAlertView dismissWithClickedButtonIndex:_userEndGameAlertView.cancelButtonIndex animated:NO];
        [self unregisterAlertView:_userEndGameAlertView];
        self.userEndGameAlertView.delegate = nil;
        self.userEndGameAlertView = nil;
    }
    if (_gameState != GameStateEnded) {
        self.loseAlertView = [[UIAlertView alloc] initWithTitle:LS_LOSE_GAME_TITLE message:LS_LOSE_GAME_DETAILS delegate:self cancelButtonTitle:LS_OK otherButtonTitles:nil];
        [_loseAlertView show];
        [self loseGame];
    }
}

- (void)loseGame {
    _gameState = GameStateEnded;
    TSGamePlayHistory *history = _gameManager.history;
    history.result = @"lose";
    [[TSGameServiceCalls sharedInstance] updateGameResult:self gameHistory:history];
}

- (void)winGame {
    _gameState = GameStateEnded;
    [self.timer invalidate];
    self.timer = nil;
    self.winAlertView = [[UIAlertView alloc] initWithTitle:LS_CONGRATULATIONS message:LS_WIN_GAME_DETAILS delegate:self cancelButtonTitle:LS_OK otherButtonTitles:nil];
    [_winAlertView show];
    TSGamePlayHistory *history = _gameManager.history;
    history.result = @"win";
    [[TSGameServiceCalls sharedInstance] updateGameResult:self gameHistory:history];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:NO completion:nil];
    if ([_delegate respondsToSelector:@selector(photoHuntViewControllerDidFinishGame:)]) {
        [_delegate photoHuntViewControllerDidFinishGame:self];
    }
}

- (void)updateFoundChangesLabel {
    _foundChangesLabel.text = [NSString stringWithFormat:@"%d/%d", [_gameManager numberOfChangesFound], [_gameManager totalNumberOfChanges]];
}

#pragma mark - PhotoHuntImageViewDelegate
- (void)photoHuntImageViewDidPress:(PhotoHuntImageView *)imageView {
    _accumulativePenalty += _gameManager.game.timePenalty;
}

#pragma mark - button pressed
- (void)endButtonPressed:(id)sender {
    if (_gameState != GameStateEnded) {
        self.userEndGameAlertView = [[UIAlertView alloc] initWithTitle:LS_END_GAME message:LS_END_GAME_DETAILS delegate:self cancelButtonTitle:LS_CANCEL otherButtonTitles:LS_END, nil];
        [_userEndGameAlertView show];
    }
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

#pragma mark - image related
- (void)setupImageViews {
    [self setupImageView:_upperImageView];
    [self setupImageView:_lowerImageView];
}

- (void)positionViews {
    _upperImageView.center = CGPointMake(_upperImageView.center.x, (_sliderContainerView.frameOriginY + 0.0f)/2);
    _lowerImageView.center = CGPointMake(_lowerImageView.center.x, (self.view.frameSizeHeight + _sliderContainerView.frameBottom)/2);
}

- (void)setupImageView:(PhotoHuntImageView *)imageView {
    imageView.userInteractionEnabled = YES;
    imageView.delegate = self;
    NSString *imageFullPath = [_gameManager originalImageFullPath];
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFullPath]];
    UIImage *image = [[UIImage alloc] initWithData:imgData];
    [imageView setImage:image];
}

#pragma mark - grid button related
- (void)photoHuntGridButton:(PhotoHuntGridButton *)button didPressedWithChangeGroup:(NSString *)changeGroup {
    if ([changeGroup isEqualToString:CHANGE_GROUP_NONE]) {
        _accumulativePenalty += _gameManager.game.timePenalty;
    } else {
        [_gameManager changeIsFound:changeGroup];
        [self updateGridButtons];
        [self updateFoundChangesLabel];
    }
}

- (void)updateGridButtons {
    for (UIView *subview in _upperImageView.subviews) {
        [subview removeFromSuperview];
    }
    for (UIView *subview in _lowerImageView.subviews) {
        [subview removeFromSuperview];
    }
    int buttonIndex = CHANGE_IMAGE_START_INDEX;
    // this for loop will handle both upper and lower image views
    for (int i=0; i<_upperImageView.frameSizeHeight; i+=GRID_HEIGHT) {
        for (int j=0; j<_upperImageView.frameSizeWidth; j+=GRID_WIDTH) {
            NSString *changeGroup = [_gameManager changeGroupOfButtonIndex:buttonIndex];
            if (![changeGroup isEqualToString:CHANGE_GROUP_NONE]) {
                CGRect rect = CGRectMake(j, i, GRID_WIDTH, GRID_HEIGHT);
                
                //upper
                PhotoHuntGridButton *upperButton = [[PhotoHuntGridButton alloc] initWithFrame:rect];
                NSString *imageFullPath = [_gameManager gridButtonImageOfButtonIndex:buttonIndex isOriginalImage:NO];
                UIImage *image = nil;
                if (imageFullPath) {
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFullPath]];
                    image = [[UIImage alloc] initWithData:imgData];
                }
                [upperButton setImage:image forState:UIControlStateNormal];
                upperButton.changeGroup = changeGroup;
                upperButton.isFound = [_gameManager isChangeFound:upperButton.changeGroup];
                upperButton.buttonIndex = buttonIndex;
                upperButton.delegate = self;
                [_upperImageView addSubview:upperButton];
                
                //lower
                PhotoHuntGridButton *lowerButton = [[PhotoHuntGridButton alloc] initWithFrame:rect];
                imageFullPath = [_gameManager gridButtonImageOfButtonIndex:buttonIndex isOriginalImage:YES];
                image = nil;
                if (imageFullPath) {
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFullPath]];
                    image = [[UIImage alloc] initWithData:imgData];
                }
                [lowerButton setImage:image forState:UIControlStateNormal];
                lowerButton.changeGroup = changeGroup;
                lowerButton.isFound = [_gameManager isChangeFound:lowerButton.changeGroup];
                lowerButton.buttonIndex = buttonIndex;
                lowerButton.delegate = self;
                [_lowerImageView addSubview:lowerButton];
            }
            buttonIndex++;
        }
    }
}

#pragma mark - PhotoHuntManagerDelegate
- (void)photoHuntManager:(PhotoHuntManager *)manager didFinishGameWithOption:(PhotoHuntDidFinishOption)option {
    if (option == PhotoHuntDidFinishOptionWin) {
        [self winGame];
    }
}

#pragma mark - TSGameServiceCallsDelegate
- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(postGameStart:game:)) {
        _gameManager.history = userInfo[@"gameHistory"];
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(postGameStart:game:)) {
        
    }
}

@end
