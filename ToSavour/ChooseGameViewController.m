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
#import "TSGame.h"
#import "TSGameDownloadManager.h"
#import "TSNavigationController.h"
#import "TSTheming.h"

#define PROGRESS_LABEL_PREFIX   [NSString stringWithFormat:@"%@...", LS_DOWNLOADING]

@interface ChooseGameViewController ()
@property (nonatomic, strong) NSMutableDictionary *buttonDict;
@property (nonatomic, strong) NSMutableArray *games;
@end

@implementation ChooseGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.games = [NSMutableArray array];
    //XXX-ML
    [self mockGames];
    //XXX-ML
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
    [self gameUpdated];
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
    //XXX-ML
    NSLog(@"finished game and come back!");
}



#pragma mark - XXX-ML
- (void)mockGames {
    NSArray *logo = @[@"http://blogs.ubc.ca/xuyueting/files/2013/09/Nike-logo-dark-with-Nike-name-freehdlogos.jpg",
                      @"http://www.littlegreenmoments.com/wp-content/uploads/2013/05/rainbow-diagram-roygbiv1.png",
                      @"http://1.bp.blogspot.com/-rU0MAHswsms/URx10AfQXvI/AAAAAAAAAQM/_Tq6WUIrBS0/s1600/Free-HD-Logo-Nike-Wallpaper.jpg",
                      @"http://www.a2zsavings.com/images/brands/adidas.jpg"
                      ];
    
    for (int i=0; i<5; i++) {
        TSGame *game = [[TSGame alloc] init];
        game.gameId = @"0001";
        game.name = @"Game 1";
        game.gamePackageURL = @"http://www.cse.ust.hk/esc/examples/proj_rome.zip";
        if (i < logo.count) {
            game.gameImageURL = logo[i];
        } else {
            game.gameImageURL = @"http://www.cuhk.edu.hk/hkiaps/conference/event/CPU%20Insignia.jpg";
        }
        game.gamePackageName = i % 2 == 0 ? @"nike" : @"AinoKishi01";
        game.timeLimit = 50.0f;
        game.timePenalty = 3.0f;
        game.validNumberOfChanges = 5;
        [_games addObject:game];
    }
}

@end
