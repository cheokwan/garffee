//
//  PhotoHuntViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "PhotoHuntViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UIView+Helpers.h>
#import "TSTheming.h"

typedef enum {
    ImageViewENumNone           = 0,
    ImageViewENumUpperImage,
    ImageViewENumLowerImage
} ImageViewENum;

@interface PhotoHuntViewController ()
//views
@property (nonatomic, strong) UIAlertView *userEndGameAlertView, *loseAlertView, *winAlertView;
@property (nonatomic, strong) NSMutableArray *activeAlertViews;

//game logic
@property (nonatomic, strong) PhotoHuntManager *gameManager;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) float accumulativePenalty;

@end

@implementation PhotoHuntViewController

- (id)initWithFilePackageName:(NSString *)packageName {
    self = (PhotoHuntViewController *)[TSTheming viewControllerWithStoryboardIdentifier:@"PhotoHuntViewController" storyboard:@"DailyGameStoryboard"];
    if (self) {
        self.filePackageName = packageName;
    }
    return self;
}

- (void)downloadGamePackage {
    //download
    [self downloadGamePackageSucceed];  //XXX-ML
}

- (void)downloadGamePackageSucceed {
    self.gameManager = [[PhotoHuntManager alloc] initWithPackageName:_filePackageName delegate:self];
    _gameManager.validNumOfChanges = 5;
    [self setupImageViews];
    //XXX-ML
    [self updateGridButtons];
    //XXX-ML
    [self startGame];
}

- (void)initialize {
    _startTime = -1.0f;
    _timeLimit = 50.0f;
    _accumulativePenalty = 0.0f;
}

//XXX-ML
- (void)tempMethods {
//    [self addGridLines];
}
//XXX-ML

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initialize];
    [self downloadGamePackage];
    
    UIBarButtonItem *endButton = [[UIBarButtonItem alloc] initWithTitle:LS_END style:UIBarButtonItemStylePlain target:self action:@selector(endButtonPressed:)];
    self.navigationItem.rightBarButtonItem = endButton;
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_DAILY_AWARD_GAME];
    _countDownSlider.userInteractionEnabled = NO;
    [_countDownSlider setValue:1.0f animated:NO];
    _sliderContainerView.backgroundColor = [UIColor lightGrayColor];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //XXX-ML
    [self tempMethods];
    //XXX-ML
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
    [self startTimer];
}

- (void)startTimer {
    _startTime = [NSDate timeIntervalSinceReferenceDate];
    if (!_timer && _timeLimit > 0.0f) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DOWN_UPDATE_INTERVAL target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    }
}

- (void)countDown:(NSTimer *)timer {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    float progress = (_timeLimit - (now - _startTime) - _accumulativePenalty) / _timeLimit;
    if (progress <= 0.0f) {
        [_countDownSlider setValue:0.0f animated:YES];
        [self.timer invalidate];
        [self timesUp];
    } else {
        [_countDownSlider setValue:progress animated:YES];
    }
}

- (void)timesUp {
    DDLogCInfo(@"time's up: %f", [NSDate timeIntervalSinceReferenceDate]);
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
    [self.timer invalidate];
    self.timer = nil;
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

#pragma mark - image related
- (void)setupImageViews {
    [self setupUppperImageView];
    [self setupLowerImageView];
}

- (void)setupUppperImageView {
    _upperImageView.userInteractionEnabled = YES;
    NSString *imageFullPath = [_gameManager originalImageFullPath];
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFullPath]];
    UIImage *image = [[UIImage alloc] initWithData:imgData];
    [_upperImageView setImage:image];
}

- (void)setupLowerImageView {
    _lowerImageView.userInteractionEnabled = YES;
    NSString *imageFullPath = [_gameManager originalImageFullPath];
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFullPath]];
    UIImage *image = [[UIImage alloc] initWithData:imgData];
    [_lowerImageView setImage:image];
}

#pragma mark - grid button related
- (void)photoHuntGridButton:(PhotoHuntGridButton *)button didPressedWithChangeGroup:(NSString *)changeGroup {
    if ([changeGroup isEqualToString:CHANGE_GROUP_NONE]) {
        _accumulativePenalty += _timePenalty;
    } else {
        [_gameManager changeIsFound:changeGroup];
        [self updateGridButtons];
    }
}

#pragma mark - need to remove
- (void)addGridLines {
    for (int i=0; i<=_upperImageView.frameSizeWidth; i+=GRID_WIDTH) {
        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(i, 0, 1, _upperImageView.frameSizeHeight)];
        verticalLine.backgroundColor = [UIColor redColor];
        [_upperImageView addSubview:verticalLine];
        verticalLine = [[UIView alloc] initWithFrame:CGRectMake(i, 0, 1, _upperImageView.frameSizeHeight)];
        verticalLine.backgroundColor = [UIColor redColor];
        [_lowerImageView addSubview:verticalLine];
    }
    
    for (int i=0; i<=_lowerImageView.frameSizeHeight; i+=GRID_HEIGHT) {
        UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, i, _upperImageView.frameSizeWidth, 1)];
        horizontalLine.backgroundColor = [UIColor redColor];
        [_upperImageView addSubview:horizontalLine];
        horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, i, _upperImageView.frameSizeWidth, 1)];
        horizontalLine.backgroundColor = [UIColor redColor];
        [_lowerImageView addSubview:horizontalLine];
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

- (void)photoHuntManager:(PhotoHuntManager *)manager didFinishGameWithOption:(PhotoHuntDidFinishOption)option {
    if (option == PhotoHuntDidFinishOptionWin) {
        [self winGame];
    }
}

@end
