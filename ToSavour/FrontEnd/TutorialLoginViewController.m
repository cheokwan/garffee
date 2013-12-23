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
#import "MFriendInfo.h"
#import "AppDelegate.h"

@interface TutorialLoginViewController ()

@end

@implementation TutorialLoginViewController

- (void)initializeView {
    _tutorialScrollView.delegate = self;
    _tutorialScrollView.pagingEnabled = YES;
    // XXX-MOCK
    NSArray *images = @[@1,
                        @1,
                        @1,
                        @1];
    NSMutableArray *imageViews = [NSMutableArray array];
    for (int i = 0; i < images.count; ++i) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 320)];
        imageView.backgroundColor = [UIColor lightGrayColor];
        // XXX-MOCK
        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        imageView.image = images[i];
        [imageViews addObject:imageView];
    }
    self.tutorialImageViews = imageViews;
    _tutorialPageControl.numberOfPages = _tutorialImageViews.count + 1;  // plus login screen
    _tutorialPageControl.pageIndicatorTintColor = [[TSTheming defaultThemeColor] colorWithAlphaComponent:0.5];
    _tutorialPageControl.currentPageIndicatorTintColor = [TSTheming defaultThemeColor];
    [_skipButton setTitle:LS_SKIP forState:UIControlStateNormal];
    [_skipButton setTitleColor:[TSTheming defaultThemeColor] forState:UIControlStateNormal];
    [_skipButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.facebookLoginButton = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_birthday", @"friends_birthday"]];
    _facebookLoginButton.delegate = self;
    [self.view bringSubviewToFront:_tutorialPageControl];
    [self.view bringSubviewToFront:_skipButton];
}

- (void)layoutView {
    [_tutorialScrollView removeAllSubviews];
    _tutorialScrollView.frame = _tutorialScrollView.superview.bounds;  // TODO: proper resize for scroll view with autolayout
    CGFloat offsetX = 0;
    for (UIImageView *imageView in _tutorialImageViews) {
        // re-center the y of the tutorial images
        imageView.center = CGPointMake(_tutorialScrollView.center.x + offsetX, _tutorialScrollView.center.y);
        [_tutorialScrollView addSubview:imageView];
        offsetX += _tutorialScrollView.bounds.size.width;
    }
    [self layoutLoginView];
    self.loginView.center = CGPointMake(_tutorialScrollView.center.x + offsetX, _tutorialScrollView.center.y);
    [_tutorialScrollView addSubview:_loginView];
    offsetX += _tutorialScrollView.bounds.size.width;
    
    _tutorialScrollView.contentSize = CGSizeMake(offsetX, _tutorialScrollView.bounds.size.height);
}

- (void)layoutLoginView {
    [self.loginView removeAllSubviews];
    _loginView.frame = CGRectMake(0, 0, _tutorialScrollView.bounds.size.width, _tutorialScrollView.bounds.size.height);
    [_facebookLoginButton sizeToFit];
    _facebookLoginButton.center = CGPointMake(_loginView.center.x, _loginView.bounds.size.height - 50.0);
    [_loginView addSubview:_facebookLoginButton];
    UILabel *descriptionText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _loginView.bounds.size.width, 20.0)];
    descriptionText.text = [NSString stringWithFormat:NSLocalizedString(@"Sign up or log in to your %@ account", @""), BRAND_NAME];
    descriptionText.font = [UIFont systemFontOfSize:12.0];
    descriptionText.tintColor = [UIColor blackColor];
    descriptionText.textAlignment = NSTextAlignmentCenter;
    descriptionText.center = CGPointMake(_facebookLoginButton.center.x, _facebookLoginButton.center.y - 40.0);
    [_loginView addSubview:descriptionText];
    // XXX-MOCK
    UIImageView *loginImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 320)];
    loginImageView.backgroundColor = [UIColor lightGrayColor];
    loginImageView.center = CGPointMake(_loginView.center.x, _loginView.center.y - 40.0);
    [_loginView addSubview:loginImageView];
    // XXX
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
    [self layoutView];
    if (_skipTutorial) {
        _tutorialScrollView.contentOffset = CGPointMake(_tutorialScrollView.contentSize.width - _tutorialScrollView.bounds.size.width, 0);
    }
}

- (UIView *)loginView {
    if (!_loginView) {
        self.loginView = [[UIView alloc] init];
    }
    return _loginView;
}

- (void)buttonPressed:(id)sender {
    if (sender == _skipButton) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowAnimatedContent animations:^{
            // fade out
            _tutorialScrollView.alpha = 0;
        } completion:^(BOOL finished) {
            // silently move to last page
            _tutorialScrollView.contentOffset = CGPointMake(_tutorialScrollView.contentSize.width - _tutorialScrollView.bounds.size.width, 0);
            [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowAnimatedContent animations:^{
                // lastly, fade back in
                _tutorialScrollView.alpha = 1;
            } completion:nil];
        }];
    }
}

- (void)dismissAfterLoggedIn {
    _facebookLoginButton.delegate = nil;
    [_spinner hide:NO];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _tutorialScrollView) {
        CGFloat pageIndex = scrollView.contentOffset.x / scrollView.bounds.size.width;
        CGFloat controlAlpha = 1.0;
        if (pageIndex >= _tutorialPageControl.numberOfPages - 2.0) {
            // if we are in second to last page and start to scroll, start to fade out
            // the controls
            CGFloat x = _tutorialPageControl.numberOfPages - pageIndex - 1.0;
            controlAlpha = MAX(2.0 * x - 1, 0.0);
        }
        
        _tutorialPageControl.alpha = controlAlpha;
        _skipButton.alpha = controlAlpha;
        
        _tutorialPageControl.currentPage = lround(pageIndex);
    }
}

#pragma mark - RestManagerResponseHandler

- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    
    if (selector == @selector(fetchFacebookAppUserInfo:)) {
        // fetched facebook info, now move onto fetching app user info with
        // facebook credentials
        [[RestManager sharedInstance] fetchAppUserInfo:self];
    }
    if (selector == @selector(fetchFacebookFriendsInfo:)) {
        // ignore for now
    }
    if (selector == @selector(fetchAppUserInfo:)) {
        // successfully logged in and registered user info, now fetch app configs
        [[RestManager sharedInstance] fetchAppConfigurations:self];
        [[RestManager sharedInstance] fetchAppProductInfo:self];
    }
    // TODO: make following calls parallel
    if (selector == @selector(fetchAppConfigurations:)) {
        // successfully fetched app configs, now fetch products info
        [[RestManager sharedInstance] fetchAppProductInfo:self];
    }
    if (selector == @selector(fetchAppProductInfo:)) {
        // successfully fetched products info, now dismiss the login view
        [self dismissAfterLoggedIn];
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    DDLogError(@"error in initial registration: %@, %@", NSStringFromSelector(selector), error);
    // TODO: handle this error better
    if (selector != @selector(fetchFacebookFriendsInfo:)) {
        // force user to go through facebook login process again to retry
        [[FBSession activeSession] closeAndClearTokenInformation];
        [_spinner hide:NO];
        self.view.hidden = NO;
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Registration Error", @"") message:NSLocalizedString(@"We cannot complete the registration process due to some unexpected error. Please try again later", @"") delegate:self cancelButtonTitle:LS_OK otherButtonTitles:nil] show];
    }
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
    _spinner.mode = MBProgressHUDModeIndeterminate;
    _spinner.labelText = LS_LOADING;
    [[RestManager sharedInstance] fetchFacebookAppUserInfo:self];
    [[RestManager sharedInstance] fetchFacebookFriendsInfo:self];
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

@end
