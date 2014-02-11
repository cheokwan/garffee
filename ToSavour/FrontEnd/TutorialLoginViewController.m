//
//  TutorialLoginViewController.m
//  ToSavour
//
//  Created by Jason Wan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TutorialLoginViewController.h"
#import "TSFrontEndIncludes.h"
#import "MUserInfo.h"
#import "MUserFacebookInfo.h"
#import "DataFetchManager.h"
#import "MBranch.h"
#import "SettingsManager.h"

@interface TutorialLoginViewController ()
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, assign) BOOL isScrollingLeft;
@property (nonatomic, strong) NSArray *tutorialPageDescriptions;
@property (nonatomic, strong) UIView *loginPageView;

@property (nonatomic, strong) UILabel *loginPageDescriptionText;
@property (nonatomic, strong) UIImageView *loginPageImageView;
@property (nonatomic, strong) UILabel *loginPageSloganText;
@end

@implementation TutorialLoginViewController
@synthesize progressTimer = _progressTimer;

- (void)initializeView {
    NSString *nibName = [UIScreen mainScreen].bounds.size.height == 480.0 ? @"TutorialPageView_iphone4" : @"TutorialPageView";
    self.tutorialPageView = (TutorialPageView *)[TSTheming viewWithNibName:nibName];
    [self.view addSubview:_tutorialPageView];
    _tutorialPageView.backgroundScrollView.delegate = self;
    _tutorialPageView.screenshotScrollView.delegate = self;
    _tutorialPageView.controlScrollView.delegate = self;
    
    _tutorialPageControl.numberOfPages = TutorialPageViewPageTotal;
    _tutorialPageControl.pageIndicatorTintColor = [[TSTheming defaultAccentColor] colorWithAlphaComponent:0.5];
    _tutorialPageControl.currentPageIndicatorTintColor = [TSTheming defaultAccentColor];
    _tutorialPageView.descriptionLabel1.text = self.tutorialPageDescriptions[0];
    _tutorialPageView.descriptionLabel2.text = self.tutorialPageDescriptions[1];
    
    [_skipButton setTitle:LS_SKIP forState:UIControlStateNormal];
    [_skipButton setTitleColor:[TSTheming defaultAccentColor] forState:UIControlStateNormal];
    [_skipButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.facebookLoginButton = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_birthday", @"friends_birthday"]];
    _facebookLoginButton.delegate = self;
    [self.view bringSubviewToFront:_tutorialPageControl];
    [self.view bringSubviewToFront:_skipButton];
    
    [self initializeLoginPage];
}

// TODO: too much code, refactor this
- (void)initializeLoginPage {
//    CGRect loginPageFrame = CGRectOffset(_tutorialPageView.bounds, _tutorialPageView.controlScrollView.contentSize.width - _tutorialPageView.controlScrollView.bounds.size.width, 0.0);  slide out effect
    CGRect loginPageFrame = _tutorialPageView.bounds;
    self.loginPageView = [[UIView alloc] initWithFrame:loginPageFrame];
    _loginPageView.backgroundColor = [UIColor clearColor];
    _loginPageView.alpha = 0.0;
    
    [_facebookLoginButton sizeToFit];
    _facebookLoginButton.center = CGPointMake(loginPageFrame.size.width / 2.0, loginPageFrame.size.height - 35.0);
    _facebookLoginButton.alpha = 0.0;
    [_tutorialPageView addSubview:_facebookLoginButton];
    
    self.loginPageDescriptionText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, loginPageFrame.size.width, 20.0)];
    _loginPageDescriptionText.text = [NSString stringWithFormat:NSLocalizedString(@"Sign up or log in to your %@ account", @""), BRAND_NAME];
    _loginPageDescriptionText.font = [UIFont systemFontOfSize:12.0];
    _loginPageDescriptionText.textColor = [TSTheming defaultAccentColor];
    _loginPageDescriptionText.textAlignment = NSTextAlignmentCenter;
    _loginPageDescriptionText.center = CGPointMake(_facebookLoginButton.center.x, _facebookLoginButton.center.y - 35.0);
    _loginPageDescriptionText.alpha = 0.0;
    [_tutorialPageView addSubview:_loginPageDescriptionText];
    
    CGFloat imageCenterY = (_tutorialPageView.bounds.size.height - _tutorialPageView.bottomBackgroundView.bounds.size.height) / 2.0;
    self.loginPageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
    _loginPageImageView.center = CGPointMake(_tutorialPageView.center.x, imageCenterY);
    _loginPageImageView.image = [UIImage imageNamed:@"app_icon"];
    _loginPageImageView.layer.masksToBounds = YES;
    _loginPageImageView.layer.cornerRadius = 80.0;
    _loginPageImageView.alpha = 0.0;
    [_tutorialPageView addSubview:_loginPageImageView];
    
    self.loginPageSloganText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, loginPageFrame.size.width, 30.0)];
    _loginPageSloganText.text = [NSString stringWithFormat:NSLocalizedString(@"Start Ordering Your Cup Today", @"")];
    _loginPageSloganText.font = [UIFont systemFontOfSize:20.0];
    _loginPageSloganText.textColor = [TSTheming defaultAccentColor];
    _loginPageSloganText.textAlignment = NSTextAlignmentCenter;
    _loginPageSloganText.center = CGPointMake(_loginPageImageView.center.x, _loginPageImageView.center.y + 110.0);
    _loginPageSloganText.alpha = 0.0;
//    [_tutorialPageView addSubview:_loginPageSloganText];
    
//    [_tutorialPageView addSubview:_loginPageView];
}

- (void)dealloc {
    [_spinner hide:NO];
    self.spinner = nil;
    [_progressTimer invalidate];
    self.progressTimer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_skipTutorial) {
        _tutorialPageView.controlScrollView.contentOffset = CGPointMake(_tutorialPageView.controlScrollView.contentSize.width - _tutorialPageView.controlScrollView.bounds.size.width, 0);
    }
}

- (NSArray *)tutorialPageDescriptions {
    if (!_tutorialPageDescriptions) {
        self.tutorialPageDescriptions = @[NSLocalizedString(@"Your Own Café, Anytime, Anywhere", @""),
                                          @"",
                                          NSLocalizedString(@"Let Your Taste Design", @""),
                                          NSLocalizedString(@"Your Own Perfect Cup", @""),
                                          NSLocalizedString(@"Make Your Purchase Right From Your Phone", @""),
                                          NSLocalizedString(@"Never Need To Wait In Line Again!", @""),
                                          NSLocalizedString(@"Pick A Store At Your Convenience", @""),
                                          NSLocalizedString(@"Your Order Will Be Ready Right Before You Arrive", @""),
                                          NSLocalizedString(@"You can always buy your friends a coffee", @""),
                                          NSLocalizedString(@"Now Anytime, Anywhere too", @"")];
    }
    return _tutorialPageDescriptions;
}

- (NSTimer *)progressTimer {
    // timer for faking an approximate progress
    if (!_progressTimer) {
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(progressTimerFired) userInfo:nil repeats:YES];
    }
    return _progressTimer;
}

- (void)setProgressTimer:(NSTimer *)progressTimer {
    [_progressTimer invalidate];
    _progressTimer = progressTimer;
}

- (void)progressTimerFired {
    static NSTimeInterval projectedRegistrationTimeNeeded = 30.0;  // in secs
    static NSTimeInterval timerStartTime = 0;
    if (!timerStartTime || [[NSDate date] timeIntervalSinceReferenceDate] > timerStartTime + projectedRegistrationTimeNeeded) {
        timerStartTime = [[NSDate date] timeIntervalSinceReferenceDate];
    }
    
    float projectedProgress = ([[NSDate date] timeIntervalSinceReferenceDate] - timerStartTime) / projectedRegistrationTimeNeeded * 0.8;  // limit to 90%
    if (_spinner && projectedProgress > _spinner.progress) {
        _spinner.progress = projectedProgress;
    }
}

- (void)buttonPressed:(id)sender {
    if (sender == _skipButton) {
//        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowAnimatedContent animations:^{
//            // fade out
//            _tutorialPageView.alpha = 0.0;
//        } completion:^(BOOL finished) {
//            // silently move to last page
//            _tutorialPageView.controlScrollView.contentOffset = CGPointMake(_tutorialPageView.controlScrollView.contentSize.width - _tutorialPageView.controlScrollView.bounds.size.width, 0);
//            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowAnimatedContent animations:^{
//                // lastly, fade back in
//                _tutorialPageView.alpha = 1.0;
//            } completion:nil];
//        }];
        
        // rapid scroll effect
        [_tutorialPageView.controlScrollView setContentOffset:CGPointMake(_tutorialPageView.controlScrollView.contentSize.width - _tutorialPageView.controlScrollView.bounds.size.width, 0) animated:YES];
    }
}

- (void)dismissAfterLoggedIn {
    [_progressTimer invalidate];
    _spinner.progress = (float)TutorialLoginRegistrationStageTotal / TutorialLoginRegistrationStageTotal;
    [SettingsManager writeSettingsValue:@(YES) forKey:SettingsManagerKeyRegistrationComplete];
    [[AppDelegate sharedAppDelegate].managedObjectContext saveToPersistentStore];
    _facebookLoginButton.delegate = nil;
    
    [MBProgressHUD hideAllHUDsForView:[AppDelegate sharedAppDelegate].window animated:NO];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)redirectOnError {
    // force user to go through facebook login process again to retry
    [[FBSession activeSession] closeAndClearTokenInformation];
    [_progressTimer invalidate];
    [MBProgressHUD hideAllHUDsForView:[AppDelegate sharedAppDelegate].window animated:YES];
    self.view.hidden = NO;
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Registration Error", @"") message:NSLocalizedString(@"We cannot complete the registration process due to some unexpected error. Please try again later", @"") delegate:self cancelButtonTitle:LS_OK otherButtonTitles:nil] show];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _tutorialPageView.controlScrollView) {
        static CGPoint lastControlScrollOffset;
        if (lastControlScrollOffset.x > _tutorialPageView.controlScrollView.contentOffset.x) {
            self.isScrollingLeft = YES;
        } else {
            self.isScrollingLeft = NO;
        }
        lastControlScrollOffset = _tutorialPageView.controlScrollView.contentOffset;
        
        CGFloat backgroundTranslatedOffsetX = _tutorialPageView.controlScrollView.contentOffset.x / _tutorialPageView.controlBackgroundScrollRatio;
        CGFloat foregroundTranslatedOffsetX = _tutorialPageView.controlScrollView.contentOffset.x / _tutorialPageView.controlForegroundScrollRatio;
        
        [_tutorialPageView.screenshotScrollView setContentOffset:CGPointMake(MIN(foregroundTranslatedOffsetX, _tutorialPageView.screenshotScrollView.contentSize.width - _tutorialPageView.screenshotScrollView.bounds.size.width), 0.0)];
        [_tutorialPageView.backgroundScrollView setContentOffset:CGPointMake(MIN(backgroundTranslatedOffsetX, _tutorialPageView.backgroundScrollView.contentSize.width - _tutorialPageView.backgroundScrollView.bounds.size.width), 0.0)];
        
        
        CGPoint pageViewCenter = CGPointMake(_tutorialPageView.bounds.size.width / 2.0, _tutorialPageView.bounds.size.height / 2.0);
        static CGPoint originalScreenshotScrollViewCenter;
        if (CGPointEqualToPoint(originalScreenshotScrollViewCenter, CGPointZero)) {
            originalScreenshotScrollViewCenter = _tutorialPageView.screenshotScrollView.center;
        }
        CGFloat pageIndex = _tutorialPageView.controlScrollView.contentOffset.x / _tutorialPageView.controlScrollView.bounds.size.width;
        
        CGFloat elementOffsetX = 0.0;
        CGFloat controlAlpha = 1.0;
        CGFloat transitionAlpha = 1.0;
        CGFloat phoneAlpha = 1.0;
        CGFloat x = pageIndex - floor(pageIndex);
        transitionAlpha = MIN(powf(2 * (x - 0.5), 2.0), 1.0);
        
        if (pageIndex >= TutorialPageViewPageTotal - 2.0) {
            // if we are in second to last page and start to scroll, start to fade out
            // the controls
            CGFloat x = TutorialPageViewPageTotal - pageIndex - 1.0;
            controlAlpha = MAX(2.0 * x - 1, 0.0);
            transitionAlpha = controlAlpha;
            
            phoneAlpha = x;
            
            // slide out the various tutorial elements
            elementOffsetX = MIN(pageIndex - (TutorialPageViewPageTotal - 2.0), 1.0) * _tutorialPageView.bounds.size.width;
        }
        _tutorialPageControl.alpha = controlAlpha;
        _skipButton.alpha = controlAlpha;
        _tutorialPageView.anchorPhoneImageView.alpha = phoneAlpha;
        _tutorialPageView.screenshotScrollView.alpha = phoneAlpha;
//        _tutorialPageView.brandNameView.alpha = controlAlpha;
        _tutorialPageView.descriptionLabel1.alpha = transitionAlpha;
        _tutorialPageView.descriptionLabel2.alpha = transitionAlpha;
//        _loginPageView.alpha = -controlAlpha + 1.0;
        _facebookLoginButton.alpha = -controlAlpha + 1.0;
        _loginPageDescriptionText.alpha = -controlAlpha + 1.0;
        _loginPageImageView.alpha = -controlAlpha + 1.0;
        _loginPageImageView.alpha = -controlAlpha + 1.0;
        _loginPageSloganText.alpha = -controlAlpha + 1.0;
        
        _tutorialPageView.anchorPhoneImageView.center = CGPointMake(pageViewCenter.x - elementOffsetX, _tutorialPageView.anchorPhoneImageView.center.y);
        _tutorialPageView.screenshotScrollView.center = CGPointMake(originalScreenshotScrollViewCenter.x - elementOffsetX, _tutorialPageView.screenshotScrollView.center.y);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == _tutorialPageView.backgroundScrollView) {
        
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == _tutorialPageView.controlScrollView) {
        CGFloat pageIndex = _tutorialPageView.screenshotScrollView.contentOffset.x / _tutorialPageView.screenshotScrollView.bounds.size.width;
        CGFloat leftPageIndex = floor(pageIndex);
        CGFloat targetPageIndex = self.isScrollingLeft ? leftPageIndex : leftPageIndex + 1.0;
        
        CGFloat controlTargetOffsetX = targetPageIndex * _tutorialPageView.screenshotScrollView.bounds.size.width * _tutorialPageView.controlForegroundScrollRatio;
        
        targetContentOffset->x = controlTargetOffsetX;
        targetContentOffset->y = 0.0;
        
        _tutorialPageControl.currentPage = targetPageIndex;
        if (targetPageIndex >= 0 && targetPageIndex < TutorialPageViewPageLogin) {
            if (_tutorialPageView.descriptionLabel1.alpha != 1.0) {
                [UIView animateWithDuration:0.2 animations:^{
                    _tutorialPageView.descriptionLabel1.alpha = 0.0;
                    _tutorialPageView.descriptionLabel2.alpha = 0.0;
                    _tutorialPageView.descriptionLabel1.text = self.tutorialPageDescriptions[(NSInteger)targetPageIndex * 2];
                    _tutorialPageView.descriptionLabel2.text = self.tutorialPageDescriptions[(NSInteger)targetPageIndex * 2 + 1];
                    _tutorialPageView.descriptionLabel1.alpha = 1.0;
                    _tutorialPageView.descriptionLabel2.alpha = 1.0;
                }];
            }
        }
    }
}

#pragma mark - RestManagerResponseHandler

- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    DDLogInfo(@"registration REST operation succeeded: %@ - %@", NSStringFromSelector(selector), userInfo);
    
    // TODO: need some way to recover if this china of fetches was interrupted by crash e.g.
    if (selector == @selector(fetchFacebookAppUserInfo:)) {
        // fetched facebook info, now move onto fetching app user info with
        // facebook credentials
        MUserFacebookInfo *facebookAppUser = [[userInfo objectForKey:@"mappingResult"] firstObject];
        if (facebookAppUser) {
            facebookAppUser.isAppUser = @YES;
            [[AppDelegate sharedAppDelegate].managedObjectContext save];
            [[RestManager sharedInstance] fetchAppUserInfo:self];
            [[DataFetchManager sharedInstance] fetchAddressBookContactsInContext:[AppDelegate sharedAppDelegate].managedObjectContext handler:nil];
            _spinner.progress = (float)TutorialLoginRegistrationStageAppUser / TutorialLoginRegistrationStageTotal;
        } else {
            DDLogError(@"unable to retrieve the mapped facebook user info");
            [self redirectOnError];
        }
    }
    if (selector == @selector(fetchAppUserInfo:)) {
        [[RestManager sharedInstance] fetchFacebookFriendsInfo:self];
        _spinner.progress = (float)TutorialLoginRegistrationStageFacebookFriends / TutorialLoginRegistrationStageTotal;
    }
    if (selector == @selector(fetchFacebookFriendsInfo:)) {
        // successfully logged in and registered user info, now fetch app configs
        [[RestManager sharedInstance] fetchAppConfigurations:self];
        [[DataFetchManager sharedInstance] discoverFacebookAppUsersInContext:[AppDelegate sharedAppDelegate].managedObjectContext handler:nil];
        [[DataFetchManager sharedInstance] discoverAddressBookAppUsersContext:[AppDelegate sharedAppDelegate].managedObjectContext handler:nil];
        _spinner.progress = (float)TutorialLoginRegistrationStageAppConfigurations / TutorialLoginRegistrationStageTotal;
    }
    // TODO: make following calls parallel
    if (selector == @selector(fetchAppConfigurations:)) {
        // successfully fetched app configs, now fetch products info
        [[RestManager sharedInstance] fetchAppProductInfo:self];
        _spinner.progress = (float)TutorialLoginRegistrationStageAppProducts / TutorialLoginRegistrationStageTotal;
    }
    if (selector == @selector(fetchAppProductInfo:)) {
        [[RestManager sharedInstance] fetchBranches:self];
        _spinner.progress = (float)TutorialLoginRegistrationStageAppStoreBranches / TutorialLoginRegistrationStageTotal;
    }
    if (selector == @selector(fetchBranches:)) {
        [[RestManager sharedInstance] fetchAppOrderHistories:self];
        _spinner.progress = (float)TutorialLoginRegistrationStageAppOrderHistories / TutorialLoginRegistrationStageTotal;
    }
    if (selector == @selector(fetchAppOrderHistories:)) {
        [[RestManager sharedInstance] fetchAppCouponInfo:self];
        _spinner.progress = (float)TutorialLoginRegistrationStageAppGiftCoupons / TutorialLoginRegistrationStageTotal;
    }
    if (selector == @selector(fetchAppCouponInfo:)) {
        [[DataFetchManager sharedInstance] cacheLocalProductImages:[AppDelegate sharedAppDelegate].managedObjectContext handler:self];
        _spinner.progress = (float)TutorialLoginRegistrationStageAppProductImages / TutorialLoginRegistrationStageTotal;
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    DDLogError(@"error in registration REST operation: %@, %@ - %@", NSStringFromSelector(selector), error, userInfo);
    [self redirectOnError];
}

#pragma mark - DataFetchManagerHandler

- (void)dataFetchManagerService:(SEL)selector succeededWithUserInfo:(NSDictionary *)userInfo {
    DDLogInfo(@"registration data fetch operation succeeded: %@ - %@", NSStringFromSelector(selector), userInfo);
    // successfully fetched everything, now dismiss the login view
    [self dismissAfterLoggedIn];
}

- (void)dataFetchManagerService:(SEL)selector failedWithError:(NSError *)error userInfo:(NSDictionary *)userInfo {
    DDLogError(@"error in registration data fetch operation: %@, %@ - %@", NSStringFromSelector(selector), error, userInfo);
    // still dismiss for now although there were errors fetching one or more images
    [self dismissAfterLoggedIn];
}

#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    DDLogInfo(@"user is logged into facebook");
    self.view.hidden = YES;
    // XXX-BUG what if user skips the permission request
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    DDLogWarn(@"user is not supposed to be able to logout facebook after initial sign in");
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    DDLogInfo(@"fetched user facebook info");
    
    // user just logged into facebook, start a spinner and do the initial fetch
    self.spinner = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedAppDelegate].window animated:YES];
    _spinner.mode = MBProgressHUDModeAnnularDeterminate;
    _spinner.labelText = LS_SIGNING_IN;
    _spinner.detailsLabelText = LS_PLEASE_WAIT;
    _spinner.progress = (float)TutorialLoginRegistrationStageFacebookAppUser / TutorialLoginRegistrationStageTotal;
    [self.progressTimer fire];  // start a timer for faking approximate progress
    [[RestManager sharedInstance] fetchFacebookAppUserInfo:self];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // TODO: this is straight from facebook, may need localization
    NSString *alertMessage, *alertTitle;
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Facebook Error";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures since they can happen
        // outside of the app. You can inspect the error for more context
        // but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        DDLogDebug(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        DDLogError(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
