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
#import "RestManager.h"
#import "DataFetchManager.h"

typedef enum {
    TutorialLoginRegistrationStageFacebookAppUser = 1,
    TutorialLoginRegistrationStageAppUser = 2,
    TutorialLoginRegistrationStageFacebookFriends = 3,
    TutorialLoginRegistrationStageAppConfigurations = 4,
    TutorialLoginRegistrationStageAppProducts = 5,
    TutorialLoginRegistrationStageAppStoreBranches = 6,
    TutorialLoginRegistrationStageAppOrderHistories = 7,
    TutorialLoginRegistrationStageAppGiftCoupons = 8,
    TutorialLoginRegistrationStageAppProductImages = 9,  // give more weight
    TutorialLoginRegistrationStageTotal = 16
} TutorialLoginRegistrationStage;

@interface TutorialLoginViewController : UIViewController<UIScrollViewDelegate, FBLoginViewDelegate, RestManagerResponseHandler, DataFetchManagerHandler>

@property (nonatomic, strong)   IBOutlet UIScrollView *tutorialScrollView;
@property (nonatomic, strong)   IBOutlet UIPageControl *tutorialPageControl;
@property (nonatomic, strong)   IBOutlet UIButton *skipButton;
@property (nonatomic, strong)   UIView *loginView;
@property (nonatomic, strong)   FBLoginView *facebookLoginButton;
@property (nonatomic, strong)   MBProgressHUD *spinner;

@property (nonatomic, strong)   NSArray *tutorialImageViews;
@property (nonatomic, assign)   BOOL skipTutorial;

@end
