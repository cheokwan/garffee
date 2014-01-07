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

typedef enum {
    FriendsListSectionAppNativeFriends = 0,
    FriendsListSectionFacebookFriends,
    FriendsListSectionAddressBookFriends,
    FriendsListSectionTotal,
} FriendsListSection;


@interface FriendsListViewController ()
@property (nonatomic, strong)   FriendsListTableViewCell *friendsListPrototypeCell;
@property (nonatomic, strong)   NSFetchedResultsController *fetchedResultsController;
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

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [(id<NSFetchedResultsSectionInfo>)(self.fetchedResultsController.sections[section]) indexTitle];
}

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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    friendCell.subtitle.text = [dateFormatter stringFromDate:friendInfo.birthday];
    
    [friendCell.avatarView removeFromSuperview];
    friendCell.avatarView = [[AvatarView alloc] initWithFrame:friendCell.avatarView.frame user:friendInfo showAccessoryImage:YES interactable:NO];
    [friendCell addSubview:friendCell.avatarView];
    friendCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [MUserInfo fetchRequestInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
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
