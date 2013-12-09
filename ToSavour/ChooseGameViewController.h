//
//  ChooseGameViewController.h
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AreYouReadyViewController.h"
#import "PhotoHuntViewController.h"

@class ChooseGameViewController;
@protocol ChooseGameViewControllerDelegate <NSObject>
- (void)chooseGameViewControllerWillDismiss:(ChooseGameViewController *)chooseGameViewContoller;
@end

@interface ChooseGameViewController : UIViewController <AreYouReadyViewControllerDelegate, PhotoHuntViewControllerDelagte>

@property (nonatomic, weak) id<ChooseGameViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *awardStrLabel, *awardDetailsLabel, *winLabel;
@property (nonatomic, strong) IBOutlet UIButton *challengeNowButton;
@property (nonatomic, strong) IBOutlet UIScrollView *gamesScrollView;

@end
