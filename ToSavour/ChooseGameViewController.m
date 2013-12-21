//
//  ChooseGameViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "ChooseGameViewController.h"

#import <AFNetworking.h>
#import <UIView+Helpers/UIView+Helpers.h>
#import "UIView+Helper.h"
#import "TSGame.h"
#import "TSGameDownloadManager.h"
#import "TSNavigationController.h"
#import "TSTheming.h"

#define PROGRESS_LABEL_PREFIX   [NSString stringWithFormat:@"%@...", LS_DOWNLOADING]

#define GAME_DICT_KEY_GAME_IMAGE_URL        @"GameImageUrl"
#define GAME_DICT_KEY_GAME_PACKAGE_URL      @"GamePackageUrl"
#define GAME_DICT_KEY_ID                    @"Id"
#define GAME_DICT_KEY_NAME                  @"Name"
#define GAME_DICT_KEY_SPONSOR_IMAGE_URL     @"SponsorImageUrl"
#define GAME_DICT_KEY_SPONSOR_NAME          @"SponsorName"
#define GAME_DICT_KEY_TIME_LIMIT            @"TimeLimit"

@interface ChooseGameViewController ()
@property (nonatomic, strong) NSMutableDictionary *buttonDict;
@property (nonatomic, strong) NSMutableArray *games;
@property (nonatomic, strong) NSString *configurationHost;
@end

@implementation ChooseGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.games = [NSMutableArray array];
    //XXX-ML
//    [self mockGames];
    //XXX-ML
    [((TSGameServiceCalls *)[TSGameServiceCalls sharedInstance]) fetchConfiguration:self];
    [self initializeView];
}

- (void)initializeView {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_DAILY_AWARD_GAME];

    _awardStrLabel.text = LS_AWARDS;
    int awardNum = 1;
    _awardDetailsLabel.text = [NSString stringWithFormat:@"%@ X %d", LS_COFFEE, awardNum];
    [_challengeNowButton setTitle:LS_CHALLENGE_NOW forState:UIControlStateNormal];
    [_challengeNowButton setTitle:LS_ALREADY_PLAYED forState:UIControlStateDisabled];
    [_challengeNowButton setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    [_challengeNowButton addTarget:self action:@selector(challengeNowButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _challengeNowButton.enabled = NO;
    [self initializeScrollView];
    _pageControl.numberOfPages = [self numberOfGames];
    [_pageControl addTarget:self action:@selector(pageControlValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    [self initializeCountDownView];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)gameChanged {
    TSGame *game = _games[[self currentPage]];
    _challengeNowButton.enabled = (game.result == GamePlayResultNone);
}

- (void)updateGameResultHistories {
    for (int i=0; i<_games.count; i++) {
        TSGame *game = _games[i];
        game.result = (i % 2 == 0);
    }
}

- (void)refetchGamesData {
    if (_configurationHost) {
        [((TSGameServiceCalls *)[TSGameServiceCalls sharedInstance]) fetchGameList:self];
    } else {
        [((TSGameServiceCalls *)[TSGameServiceCalls sharedInstance]) fetchConfiguration:self];
    }
}

#pragma mark - button pressed
- (void)cancelButtonPressed:(id)sender {
    if ([_delegate respondsToSelector:@selector(chooseGameViewControllerWillDismiss:)]) {
        [_delegate chooseGameViewControllerWillDismiss:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)challengeNowButtonPressed:(id)sender {
    _progressPanel.hidden = NO;
    [self.view bringSubviewToFront:_progressPanel];
    [_progressPanel bringSubviewToFront:_progressContainerView];
    [self downloadPackage:[_games objectAtIndex:[self currentPage]]];
}

#pragma mark - download game package
- (void)downloadPackage:(TSGame *)game {
    _progressLabel.text = [NSString stringWithFormat:@"%@ %d%%", PROGRESS_LABEL_PREFIX, 0];
    [_progressView setProgress:0.0f animated:NO];
    [[TSGameDownloadManager getInstance] downloadGamePackage:game.gamePackageURL packageName:game.gamePackageName success:^(NSString *fileFullPath) {
        game.gamePackageFullPath = fileFullPath;
        [self downloadSucceed:game];
    }failure:^(NSString *fileFullPath) {
        [self downloadFailed:game];
    }progress:^(long long currentBytesRead, long long expectedTotalBytesRead){
        [self updateDownloadProgress:(float)currentBytesRead/expectedTotalBytesRead];
    }];
}

- (void)downloadSucceed:(TSGame *)game {
    PhotoHuntManager *manager = [[PhotoHuntManager alloc] initWithGame:game delegate:self];
    if (manager) {
        // PhotoHuntManger init method will return nil if unzip game package failed
        [_progressPanel bringSubviewToFront:_countDownView];
        _countDownView.frameOriginX = _countDownView.superview.frameRight;
        [UIView animateWithDuration:0.5f animations:^{
            _countDownView.frameOriginX = 0.0f;
        } completion:^(BOOL finished){
            [self startCountDown:manager];
        }];
    }
}

- (void)downloadFailed:(TSGame *)game {
    [self hideProgressPanel];
    UIAlertView *downloadFailedAlertView = [[UIAlertView alloc] initWithTitle:LS_DOWNLOAD_FAILED message:LS_DOWNLOAD_FAILED_DETAILS delegate:nil cancelButtonTitle:LS_OK otherButtonTitles:nil];
    [downloadFailedAlertView show];
}

- (void)updateDownloadProgress:(float)progress {
    float newProgress = progress;
    if (newProgress >= 1.0f) {
        newProgress = 0.99f;
    } else if (newProgress < 0.0f) {
        newProgress = 0.0f;
    }
    if (newProgress > _progressView.progress) {
        [_progressView setProgress:newProgress animated:YES];
        _progressLabel.text = [NSString stringWithFormat:@"%@ %.0f%%", PROGRESS_LABEL_PREFIX, newProgress * 100];
    }
}

#pragma mark - PhotoHuntManagerDeleagte
- (void)photoHuntManager:(PhotoHuntManager *)manager didFaiUnzipGame:(TSGame *)game {
    [self hideProgressPanel];
    UIAlertView *unzipPackageFailedAlertView = [[UIAlertView alloc] initWithTitle:LS_UNZIP_FAILED message:LS_UNZIP_FAILED_DETAILS delegate:nil cancelButtonTitle:LS_OK otherButtonTitles:nil];
    [unzipPackageFailedAlertView show];
}

- (void)photoHuntManager:(PhotoHuntManager *)manager didFailVerifyGame:(TSGame *)game reason:(PackageVerifyFailedOption)failOption {
    [self hideProgressPanel];
    UIAlertView *unzipPackageFailedAlertView = [[UIAlertView alloc] initWithTitle:LS_UNZIP_FAILED message:LS_UNZIP_FAILED_DETAILS delegate:nil cancelButtonTitle:LS_OK otherButtonTitles:nil];
    [unzipPackageFailedAlertView show];
}

#pragma mark - scroll view related
- (void)initializeScrollView {
    for (UIView *subview in _gamesScrollView.subviews) {
        [subview removeFromSuperview];
    }
    float width = 0.0f;
    for (int i=0; i<[self numberOfGames]; i++) {
        CGRect rect = CGRectMake(i*_gamesScrollView.frameSizeWidth, 0, _gamesScrollView.frameSizeWidth, _gamesScrollView.frameSizeHeight);
        UIImageView *anImageView = [[UIImageView alloc] initWithFrame:rect];
        TSGame *game = [_games objectAtIndex:i];
        [anImageView setImageWithURL:[NSURL URLWithString:game.gameImageURL]];
        [_gamesScrollView addSubview:anImageView];
        width += _gamesScrollView.frameSizeWidth;
    }
    _gamesScrollView.contentSize = CGSizeMake(width, _gamesScrollView.frameSizeHeight);
    _gamesScrollView.showsHorizontalScrollIndicator = NO;
    _gamesScrollView.showsVerticalScrollIndicator = NO;
    _gamesScrollView.pagingEnabled = YES;
}

- (int)currentPage {
    return (int)_gamesScrollView.contentOffset.x / _gamesScrollView.frameSizeWidth;
}

- (CGPoint)contentOffsetOfPage:(int)page {
    return CGPointMake(_gamesScrollView.frameSizeWidth * page, 0.0f);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControl.currentPage = [self currentPage];
    [self gameChanged];
}

- (void)pageControlValueDidChanged:(id)sender {
    UIPageControl *pageControl = (UIPageControl *)sender;
    _gamesScrollView.contentOffset = [self contentOffsetOfPage:pageControl.currentPage];
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
    _progressPanel.hidden = YES;
    _progressPanel.userInteractionEnabled = NO;
}

- (void)startCountDown:(PhotoHuntManager *)gameManager {
    [self countDown:@(0)];
    float interval = 0.5f;
    [self performSelector:@selector(countDown:) withObject:@(3) afterDelay:interval];
    interval += COUNT_DOWN_INTERVAL;
    [self performSelector:@selector(countDown:) withObject:@(2) afterDelay:interval];
    interval += COUNT_DOWN_INTERVAL;
    [self performSelector:@selector(countDown:) withObject:@(1) afterDelay:interval];
    interval += COUNT_DOWN_INTERVAL;
    [self performSelector:@selector(proceedFromCountDown:) withObject:gameManager afterDelay:interval];
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
    return _games.count;
}

- (void)proceedFromCountDown:(PhotoHuntManager *)gameManager {
    [self hideProgressPanel];
    [self countDown:@(0)];
    PhotoHuntViewController *photoHuntercontroller = [[PhotoHuntViewController alloc] initWithGameManager:gameManager];
    TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:photoHuntercontroller];
    photoHuntercontroller.delegate = self;
    [self presentViewController:naviController animated:NO completion:nil];
}

- (void)hideProgressPanel {
    _progressPanel.hidden = YES;
    [self.view sendSubviewToBack:_progressPanel];
}

#pragma mark - PhotoHuntViewControllerDelegate / related
- (void)photoHuntViewControllerDidFinishGame:(PhotoHuntViewController *)controller {
    [self refetchGamesData];
    //XXX-ML
    NSLog(@"finished game and come back!");
}

#pragma TSGameServiceCallDelegate
- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    NSError *error = nil;
    if (selector == @selector(fetchGameHistories:)) {
        NSData *data = userInfo[@"responseObject"];
        if (data) {
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (!jsonArray) {
                NSLog(@"Error parsing JSON: %@", error);
            } else {
                NSLog(@"");
                [self updateGameResultHistories];
            }
        }
    } else if (selector == @selector(fetchGameList:)) {
        NSData *data = userInfo[@"responseObject"];
        if (data) {
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            if (!jsonArray) {
                NSLog(@"Error parsing JSON: %@", error);
            } else {
                for(NSDictionary *item in jsonArray) {
                    NSLog(@"Item: %@", item);
                    TSGame *game = [[TSGame alloc] init];
                    game.gameId = item[GAME_DICT_KEY_ID];
                    game.name = item[GAME_DICT_KEY_NAME];
                    NSString *packageURL = item[GAME_DICT_KEY_GAME_PACKAGE_URL];
                    packageURL = [packageURL stringByDeletingPathExtension];
                    packageURL = [packageURL lastPathComponent];
                    game.gamePackageName = packageURL;
                    game.gameImageURL = [NSString stringWithFormat:@"%@%@", _configurationHost, item[GAME_DICT_KEY_GAME_IMAGE_URL]];
                    game.gamePackageURL = [NSString stringWithFormat:@"%@%@", _configurationHost, item[GAME_DICT_KEY_GAME_PACKAGE_URL]];
                    game.timeLimit = [item[GAME_DICT_KEY_TIME_LIMIT] intValue];
                    game.validNumberOfChanges = 5;
                    [_games addObject:game];
                }
            }
            NSLog(@"");
        }
        [self initializeScrollView];
        [[TSGameServiceCalls sharedInstance] fetchGameHistories:self];
    } else if (selector == @selector(fetchConfiguration:)) {
        NSData *data = userInfo[@"responseObject"];
        if (data) {
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            if (!jsonArray) {
                NSLog(@"Error parsing JSON: %@", error);
            } else {
                for(NSDictionary *item in jsonArray) {
                    if (item[@"Value"]) {
                        self.configurationHost = item[@"Value"];
                    }
                }
            }
            if (_configurationHost) {
                [((TSGameServiceCalls *)[TSGameServiceCalls sharedInstance]) fetchGameList:self];
            } else {
                DDLogCError(@"no configuration host is found");
            }
        }
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    NSLog(@"");
}

@end
