//
//  ChooseGameViewController.h
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MBProgressHUD/MBProgressHUD.h>

#import "CountDownButton.h"
#import "PhotoHuntManager.h"
#import "PhotoHuntViewController.h"
#import "RestManager.h"

#define COUNT_DOWN_INTERVAL     1.0f


@class ChooseGameViewController;
@protocol ChooseGameViewControllerDelegate <NSObject>
- (void)chooseGameViewControllerWillDismiss:(ChooseGameViewController *)chooseGameViewContoller;
@end

@interface ChooseGameViewController : UIViewController <PhotoHuntViewControllerDelagte, UIScrollViewDelegate, PhotoHuntManagerDelegate, RestManagerResponseHandler>

@property (nonatomic, weak) id<ChooseGameViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIView *awardContainerView;
@property (nonatomic, strong) IBOutlet UILabel *awardStrLabel, *awardDetailsLabel, *winLabel;
@property (nonatomic, strong) IBOutlet UIButton *challengeNowButton;
@property (nonatomic, strong) IBOutlet UIScrollView *gamesScrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIImageView *promotionImageView;
@property (nonatomic, strong) IBOutlet UILabel *sponsorByLabel;
@property (nonatomic, strong) IBOutlet UILabel *didPlayedGameLabel;

@property (nonatomic, strong) IBOutlet UIView *progressPanel;
@property (nonatomic, strong) IBOutlet UIView *progressContainerView;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UILabel *progressLabel;
@property (nonatomic, strong) IBOutlet UIView *countDownView;
@property (nonatomic, strong) IBOutlet CountDownButton *num1Button, *num2Button, *num3Button;

@property (nonatomic, strong) MBProgressHUD *spinner;

@end
