//
//  TutorialLoginViewController.h
//  ToSavour
//
//  Created by Jason Wan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "TutorialPageView.h"
#import "SessionManager.h"


@interface TutorialLoginViewController : UIViewController<UIScrollViewDelegate, FBLoginViewDelegate, SessionManagerDelegate>

@property (nonatomic, strong)   TutorialPageView *tutorialPageView;
@property (nonatomic, strong)   IBOutlet UIPageControl *tutorialPageControl;
@property (nonatomic, strong)   IBOutlet UIButton *skipButton;
@property (nonatomic, strong)   UIView *loginView;
@property (nonatomic, strong)   FBLoginView *facebookLoginButton;
@property (nonatomic, strong)   MBProgressHUD *spinner;

@property (nonatomic, assign)   BOOL skipTutorial;

@end
