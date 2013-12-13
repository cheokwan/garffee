//
//  PhotoHuntViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "PhotoHuntViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SSZipArchive.h>
#import <UIView+Helpers.h>
#import "TSTheming.h"

#define COUNT_DOWN_UPDATE_INTERVAL  0.01f
#define GRID_WIDTH                  10.0f
#define GRID_HEIGHT                 10.0f

typedef enum {
    DownloadSucceedNone         = 0,
    DownloadSucceedUpperImage   = 1 << 0,
    DownloadSucceedLowerImage   = 1 << 1
} DownloadSucceed;

typedef enum {
    ImageViewENumNone           = 0,
    ImageViewENumUpperImage,
    ImageViewENumLowerImage
} ImageViewENum;

@interface PhotoHuntViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIAlertView *userEndGameAlertView, *loseAlertView, *winAlertView;
@property (nonatomic, strong) NSMutableArray *activeAlertViews;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) DownloadSucceed downloadSucceedBits;
@property (nonatomic, strong) NSString *packagePath;
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
    _startTime = -1.0f;
    _downloadSucceedBits = DownloadSucceedNone;
    self.filePackageName = @"AinoKishi01";
    
    UIBarButtonItem *endButton = [[UIBarButtonItem alloc] initWithTitle:LS_END style:UIBarButtonItemStylePlain target:self action:@selector(endButtonPressed:)];
    self.navigationItem.rightBarButtonItem = endButton;
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_DAILY_AWARD_GAME];
    _countDownSlider.userInteractionEnabled = NO;
    [_countDownSlider setValue:1.0f animated:NO];
    _sliderContainerView.backgroundColor = [UIColor lightGrayColor];
    
    
    //XXX-ML
    [self addGridLines];
    [self unzipFile:@"AinoKishi01" extension:@"zip"];
    [self browseDirectory:@"AinoKishi01"];
    //XXX-ML
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupImageViews];
    
    //XXX-ML
    [self addGridButtons];
    //XXX-ML
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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

#pragma mark - image related
- (void)setupImageViews {
    [self setupUppperImageView];
    [self setupLowerImageView];
}

- (void)setupUppperImageView {
    _upperImageView.userInteractionEnabled = YES;
    NSString *imageFullPath = [NSString stringWithFormat:@"%@/%@", _packagePath, [self originalImageStr:_filePackageName]];
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFullPath]];
    UIImage *image = [[UIImage alloc] initWithData:imgData];
    [_upperImageView setImage:image];
    
    
//    __block PhotoHuntViewController *blockSelf = self;
//    NSURL *url = [NSURL URLWithString:@"http://static.hothdwallpaper.net/51b0bb7b5442c28562.jpg"];
//    [_upperImageView setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
//        blockSelf.downloadSucceedBits |= DownloadSucceedUpperImage;
//        if ([blockSelf allDownloadsSucceed]) {
//            [blockSelf startGame];
//        }
//    }];
}

- (void)setupLowerImageView {
    __block PhotoHuntViewController *blockSelf = self;
    NSURL *url = [NSURL URLWithString:@"http://spasalon.com/wp-content/uploads/2012/02/light-blue-background.jpg"];
    [_lowerImageView setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        blockSelf.downloadSucceedBits |= DownloadSucceedLowerImage;
        if ([blockSelf allDownloadsSucceed]) {
            [blockSelf startGame];
        }
    }];
}

- (BOOL)allDownloadsSucceed {
    return (_downloadSucceedBits == (DownloadSucceedUpperImage|ImageViewENumLowerImage));
}

- (void)downloadImageFailed:(ImageViewENum)imageView {
    
}

#pragma mark - grid button related
- (void)photoHuntGridButton:(PhotoHuntGridButton *)button didPressedWithChangeGroup:(int)changeGroup {
    NSLog(@"button : %@; changeGroup : %d", button, changeGroup);
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

- (BOOL)unzipFile:(NSString *)fileName extension:(NSString *)extension {
    if (!_filePackageName) {
        NSLog(@"_filePackageName is nil");
        return NO;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@", documentsDirectory, fileName, extension];
    NSString *zipPath = filePath;
    
    return [SSZipArchive unzipFileAtPath:zipPath toDestination:documentsDirectory];
}

- (void)browseDirectory:(NSString *)directoryName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.packagePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, directoryName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:_packagePath error:&error];
    NSLog(@"");
}

- (NSString *)originalImageStr:(NSString *)packageName {
    return [NSString stringWithFormat:@"%@_org.jpg", packageName];
}

- (void)addGridButtons {
    for (int i=0; i<_upperImageView.frameSizeWidth; i+=GRID_WIDTH) {
        for (int j=0; j<_upperImageView.frameSizeHeight; j+=GRID_HEIGHT) {
            CGRect rect = CGRectMake(i, j, GRID_WIDTH, GRID_HEIGHT);
            PhotoHuntGridButton *button = [[PhotoHuntGridButton alloc] initWithFrame:rect];
            button.delegate = self;
            [_upperImageView addSubview:button];
//            [button addTarget:button action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

@end
