//
//  ChooseGameViewController.h
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChooseGameViewController;
@protocol ChooseGameViewControllerDelegate <NSObject>
- (void)chooseGameViewControllerWillDismiss:(ChooseGameViewController *)chooseGameViewContoller;
@end

@interface ChooseGameViewController : UIViewController

@property (nonatomic, weak) id<ChooseGameViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *awardStrLabel, *awardDetailsLabel, *challengeNowStrLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *gamesScrollView;

@end
