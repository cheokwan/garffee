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

typedef enum {
    FriendsListSectionAppNativeFriends = 0,
    FriendsListSectionFacebookFriends,
    FriendsListSectionAddressBookFriends,
    FriendsListSectionTotal,
} FriendsListSection;


@interface FriendsListViewController ()
@property (nonatomic, strong)   FriendsListTableViewCell *friendsListPrototypeCell;
@property (nonatomic, strong)   NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly)   UIView *sendGiftAccessoryView;
@property (nonatomic, readonly)   UIView *sendInviteAccessoryView;
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
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_FRIENDS];
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

- (void)buttonPressed:(id)sender event:(id)event {
    UITouch *touch = [[event allTouches] anyObject];
    NSIndexPath *indexPath = [_friendsList indexPathForRowAtPoint:[touch locationInView:_friendsList]];
    MUserInfo *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([friend.userType intValue] == MUserInfoUserTypeAppNativeUser) {
        MainTabBarController *tabBarController = [AppDelegate sharedAppDelegate].mainTabBarController;
        CartViewController *cart = (CartViewController *)[tabBarController viewControllerAtTab:MainTabBarControllerTabCart];
        if ([cart isKindOfClass:CartViewController.class]) {
            [cart updateRecipient:friend];
        }
        [tabBarController switchToTab:MainTabBarControllerTabCart animated:YES];
    } else if ([friend.userType intValue] == MUserInfoUserTypeFacebookUser ||
               [friend.userType intValue] == MUserInfoUserTypeAddressBookUser) {
        // TODO: invite logic goes here
    }
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
    return self.fetchedResultsController.sections.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [(id<NSFetchedResultsSectionInfo>)(self.fetchedResultsController.sections[section]) indexTitle];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(id<NSFetchedResultsSectionInfo>)(self.fetchedResultsController.sections[section]) numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.friendsListPrototypeCell.bounds.size.height;
}

- (FriendsListTableViewCell *)friendsListPrototypeCell {
    if (!_friendsListPrototypeCell) {
        self.friendsListPrototypeCell = [_friendsList dequeueReusableCellWithIdentifier:NSStringFromClass(FriendsListTableViewCell.class)];
    }
    return _friendsListPrototypeCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(FriendsListTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FriendsListTableViewCell *friendCell = (FriendsListTableViewCell *)cell;
    MUserInfo *friendInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    friendCell.title.text = friendInfo.name;
    friendCell.subtitle.text = [friendInfo.birthday defaultStringRepresentation];  // XXX-TEST
    
    [friendCell.avatarView removeFromSuperview];
    friendCell.avatarView = [[AvatarView alloc] initWithFrame:friendCell.avatarView.frame user:friendInfo showAccessoryImage:YES interactable:NO];
    [friendCell addSubview:friendCell.avatarView];
    friendCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    MUserInfo *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([friend.userType intValue] == MUserInfoUserTypeAppNativeUser) {
        friendCell.accessoryView = self.sendGiftAccessoryView;
    } else if ([friend.userType intValue] == MUserInfoUserTypeFacebookUser ||
               [friend.userType intValue] == MUserInfoUserTypeAddressBookUser) {
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
            [self configureCell:[_friendsList cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

@end
