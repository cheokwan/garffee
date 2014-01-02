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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController fetchedObjects].count;
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
    friendCell.avatarView = [[AvatarView alloc] initWithFrame:friendCell.avatarView.frame avatarImageURL:friendInfo.URLForProfileImage accessoryImageURL:[NSURL URLWithString:@"http://files.softicons.com/download/social-media-icons/simple-icons-by-dan-leech/png/128x128/facebook.png"] interactable:NO];  // XXX-TEST
    [friendCell addSubview:friendCell.avatarView];
    friendCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [MUserInfo fetchRequestInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isAppUser = %@", @NO];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:NO];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        fetchRequest.fetchBatchSize = 20;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[AppDelegate sharedAppDelegate].managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];  // XXX-FIX cache name
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
