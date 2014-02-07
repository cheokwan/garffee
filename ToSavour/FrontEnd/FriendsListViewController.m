//
//  FriendsListViewController.m
//  ToSavour
//
//  Created by Jason Wan on 12/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "FriendsListViewController.h"
#import "FriendsListTableViewCell.h"
#import "TSFrontEndIncludes.h"
#import <FacebookSDK/FacebookSDK.h>  // XXX-TEST
#import "AvatarView.h"
#import "MUserInfo.h"
#import "CartViewController.h"
#import <MessageUI/MessageUI.h>

typedef enum {
    FriendsListSectionAppNativeFriends = 0,
    FriendsListSectionFacebookFriends,
    FriendsListSectionAddressBookFriends,
    FriendsListSectionTotal,
} FriendsListSection;


@interface FriendsListViewController ()
@property (nonatomic, strong)   FriendsListTableViewCell *friendsListPrototypeCell;
@property (nonatomic, strong)   NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly) UIView *sendGiftAccessoryView;
@property (nonatomic, readonly) UIView *sendInviteAccessoryView;

@property (nonatomic, strong)   NSMutableArray *searchResults;
@property (nonatomic, strong)   NSTimer *searchTimer;
@property (nonatomic, assign)   BOOL isSearching;
@end

@implementation FriendsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initializeView {
    _friendsList.delegate = self;
    _friendsList.dataSource = self;
    for (UIView *view in self.view.subviews) {
        if ([view respondsToSelector:@selector(setScrollsToTop:)]) {
            [view performSelector:@selector(setScrollsToTop:) withObject:@NO];
        }
    }
    _friendsList.scrollsToTop = YES;
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_FRIENDS];
    
    self.searchDisplayController.searchResultsTableView.delegate = self;
    self.searchDisplayController.delegate = self;
    [_searchBar setTintColor:[TSTheming defaultAccentColor]];
    _searchBar.placeholder = LS_SEARCH_FRIENDS;
    self.searchResults = [NSMutableArray array];
    
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(FriendsListTableViewCell.class) bundle:[NSBundle mainBundle]];
    [_friendsList registerNib:nib forCellReuseIdentifier:NSStringFromClass(FriendsListTableViewCell.class)];
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:NSStringFromClass(FriendsListTableViewCell.class)];
    
    // hiding the search bar initially
    CGRect newBounds = _friendsList.bounds;
    newBounds.origin.y = newBounds.origin.y + _searchBar.bounds.size.height;
    _friendsList.bounds = newBounds;
    
    // XXX TODO: properly fix this, for some reason the friend list contentSize got change to 0 after search
    [self addObserver:self forKeyPath:@"self.friendsList.contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"self.friendsList.contentSize"]) {
        NSValue *newChange = change[NSKeyValueChangeNewKey];
        CGSize newSize;
        [newChange getValue:&newSize];
        if (newSize.width == 0 && newSize.height == 0) {
            NSValue *oldChange = change[NSKeyValueChangeOldKey];
            CGSize oldSize;
            [oldChange getValue:&oldSize];
            
            _friendsList.contentSize = CGSizeMake(oldSize.width, oldSize.height);
            DDLogWarn(@"detected changing friend list contentSize to 0, setting back to old size:<%f, %f>", oldSize.width, oldSize.height);
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_searchTimer invalidate];
    self.searchTimer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)invitationBody {
    return [NSString stringWithFormat:@"Check out %@ iOS", BRAND_NAME];
}

- (NSString *)invitationTitle {
    return [NSString stringWithFormat:NSLocalizedString(@"Come Check Out %@", @""), BRAND_NAME];
}

- (void)showInvitationFeedbackOK {
    NSString *feedbackMessage = [NSString stringWithFormat:NSLocalizedString(@"You have successfully invited your friend to try %@, Thank you for supporting us!", @""), BRAND_NAME];
    [[[UIAlertView alloc] initWithTitle:nil message:feedbackMessage delegate:nil cancelButtonTitle:LS_OK otherButtonTitles:nil, nil] show];
}

- (void)showInvitationFeedbackError {
    NSString *feedbackMessage = NSLocalizedString(@"Your invitation message failed to be sent out, please try again later", @"");
    [[[UIAlertView alloc] initWithTitle:LS_ERROR message:feedbackMessage delegate:nil cancelButtonTitle:LS_OK otherButtonTitles:nil, nil] show];
}

- (void)buttonPressed:(id)sender event:(id)event {
    UITouch *touch = [[event allTouches] anyObject];
    NSIndexPath *indexPath = [_friendsList indexPathForRowAtPoint:[touch locationInView:_friendsList]];
    
    MUserInfo *friend = nil;
    if ([self isSearching]) {
        friend = indexPath.row < self.searchResults.count ? self.searchResults[indexPath.row] : nil;
        [_searchBar resignFirstResponder];
    } else {
        friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    if ([friend.userType intValue] == MUserInfoUserTypeAppNativeUser) {
        MainTabBarController *tabBarController = [AppDelegate sharedAppDelegate].mainTabBarController;
        CartViewController *cart = (CartViewController *)[tabBarController viewControllerAtTab:MainTabBarControllerTabCart];
        if ([cart isKindOfClass:CartViewController.class]) {
            [cart updateRecipient:friend];
        }
        [tabBarController switchToTab:MainTabBarControllerTabCart animated:YES];
    } else if ([friend.userType intValue] == MUserInfoUserTypeFacebookUser) {
        NSMutableDictionary *params = [@{@"message": [self invitationBody],
                                         @"title": [self invitationTitle],
                                         @"to": friend.facebookID,
                                         @"redirect_url": @"http://store.apple.com/hk"} mutableCopy];
        NSString *facebookAppID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
        if (facebookAppID) {
            [params setObject:facebookAppID forKey:@"app_id"];
        } else {
            DDLogError(@"failed to read Facebook app ID from Info.plist");
        }
        
        [FBWebDialogs presentDialogModallyWithSession:[FBSession activeSession] dialog:@"apprequests" parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
            if (result == FBWebDialogResultDialogCompleted) {
                DDLogInfo(@"successfully invited facebook friend: %@, resultURL: %@", friend.facebookID, resultURL);
                [self showInvitationFeedbackOK];
            } else if (result == FBWebDialogResultDialogNotCompleted && error) {
                DDLogError(@"failed to invite facebook friend: %@", error);
                [self showInvitationFeedbackError];
            }
        }];
    } else if ([friend.userType intValue] == MUserInfoUserTypeAddressBookUser) {
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
            messageComposer.messageComposeDelegate = self;
            messageComposer.body = [self invitationBody];
            messageComposer.recipients = @[[[friend.phoneNumber decodeCommaSeparatedString] firstObject]];  // TODO: for better experience, choose a HK number
            [self presentViewController:messageComposer animated:YES completion:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Your device is not configured for sending messages, please enable iMessage to continue inviting your friend", @"") delegate:nil cancelButtonTitle:LS_OK otherButtonTitles:nil, nil] show];
        }
    }
}

#pragma mark - UISearchBarDelegate, UISearchDisplayDelegate

- (BOOL)isSearching {
    return [_searchBar.text trimmedWhiteSpaces].length > 0;
}

- (void)filterFriendsListForSearch {
    NSString *searchText = _searchBar.text;
    [self.searchResults removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", searchText];
        [self.searchResults addObjectsFromArray:[self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:searchPredicate]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        });
    });
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [_searchTimer invalidate];
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(filterFriendsListForSearch) userInfo:nil repeats:NO];
    return NO;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (UIView *)sendGiftAccessoryView {
    CGFloat frameDimension = self.friendsListPrototypeCell.bounds.size.height - 30.0;
    UIButton *giftButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, frameDimension, frameDimension)];
    [giftButton setImage:[UIImage imageNamed:@"ico_gift"] forState:UIControlStateNormal];
    [giftButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 3.0, 0.0, -3.0)];
    giftButton.clipsToBounds = NO;
    [giftButton addTarget:self action:@selector(buttonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(-5.0, 0.0, 0.5, frameDimension)];
    line.backgroundColor = [UIColor lightGrayColor];
    [giftButton addSubview:line];
    return giftButton;
}

- (UIView *)sendInviteAccessoryView {
    CGFloat frameDimension = self.friendsListPrototypeCell.bounds.size.height - 30.0;
    UIButton *inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, frameDimension, frameDimension)];
    [inviteButton setTitle:LS_INVITE forState:UIControlStateNormal];
    [inviteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    inviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    inviteButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [inviteButton setImage:nil forState:UIControlStateNormal];
    [inviteButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 3.0, 0.0, -3.0)];
    inviteButton.clipsToBounds = NO;
    [inviteButton addTarget:self action:@selector(buttonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(-5.0, 0.0, 0.5, frameDimension)];
    line.backgroundColor = [UIColor lightGrayColor];
    [inviteButton addSubview:line];
    return inviteButton;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _friendsList) {
        return self.fetchedResultsController.sections.count;
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    return 0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [(id<NSFetchedResultsSectionInfo>)(self.fetchedResultsController.sections[section]) indexTitle];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _friendsList) {
        return [(id<NSFetchedResultsSectionInfo>)(self.fetchedResultsController.sections[section]) numberOfObjects];
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.friendsListPrototypeCell.bounds.size.height;
}

- (FriendsListTableViewCell *)friendsListPrototypeCell {
    if (!_friendsListPrototypeCell) {
        self.friendsListPrototypeCell = [_friendsList dequeueReusableCellWithIdentifier:NSStringFromClass(FriendsListTableViewCell.class)];
        self.searchDisplayController.searchResultsTableView.rowHeight = _friendsListPrototypeCell.frame.size.height;
    }
    return _friendsListPrototypeCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _friendsList || tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(FriendsListTableViewCell.class) forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath forTableView:tableView];
        return cell;
    }
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView {
    FriendsListTableViewCell *friendCell = (FriendsListTableViewCell *)cell;
    
    MUserInfo *friendInfo = nil;
    if (tableView == _friendsList) {
        friendInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        friendInfo = indexPath.row < self.searchResults.count ? self.searchResults[indexPath.row] : nil;
    }
    friendCell.title.text = friendInfo.name;
    friendCell.subtitle.text = [friendInfo.birthday defaultStringRepresentation];  // XXX-TEST
    
    [friendCell.avatarView removeFromSuperview];
    friendCell.avatarView = [[AvatarView alloc] initWithFrame:friendCell.avatarView.frame user:friendInfo showAccessoryImage:YES interactable:NO];
    [friendCell addSubview:friendCell.avatarView];
    friendCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([friendInfo.userType intValue] == MUserInfoUserTypeAppNativeUser) {
        friendCell.accessoryView = self.sendGiftAccessoryView;
    } else if ([friendInfo.userType intValue] == MUserInfoUserTypeFacebookUser ||
               [friendInfo.userType intValue] == MUserInfoUserTypeAddressBookUser) {
        friendCell.accessoryView = self.sendInviteAccessoryView;
    }
}


#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [MUserInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isAppUser = %@", @NO];
        NSSortDescriptor *sdUserType = [[NSSortDescriptor alloc] initWithKey:@"userType" ascending:YES];
        NSSortDescriptor *sdName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        fetchRequest.sortDescriptors = @[sdUserType, sdName];
        fetchRequest.fetchBatchSize = 20;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[AppDelegate sharedAppDelegate].managedObjectContext sectionNameKeyPath:@"userType" cacheName:nil];  // XXX-FIX cache name
        _fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            DDLogError(@"error fetching friends list: %@", error);
            _fetchedResultsController = nil;
        }
    }
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_friendsList beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [_friendsList insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [_friendsList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[_friendsList cellForRowAtIndexPath:indexPath] atIndexPath:indexPath forTableView:_friendsList];
            break;
        case NSFetchedResultsChangeMove:
            [_friendsList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_friendsList insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_friendsList endUpdates];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled: {
            // do nothing
        }
            break;
        case MessageComposeResultSent: {
            [self showInvitationFeedbackOK];
        }
            break;
        case MessageComposeResultFailed: {
            [self showInvitationFeedbackError];
        }
            break;
    }
    controller.recipients = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // XXX work around for 64-bit simulator unrecognized selector
}

@end
