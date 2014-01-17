//
//  AccountViewController.m
//  ToSavour
//
//  Created by Jason Wan on 13/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "AccountViewController.h"
#import "AccountInfoTableViewCell.h"
#import "TransactionHistoryTableViewCell.h"
#import "TSFrontEndIncludes.h"
#import "MOrderInfo.h"
#import "MItemInfo.h"
#import "MProductInfo.h"

@interface AccountViewController ()
@property (nonatomic, strong)   AccountInfoTableViewCell *accountInfoPrototypeCell;
@property (nonatomic, strong)   TransactionHistoryTableViewCell *transactionHistoryPrototypeCell;
@property (nonatomic, strong)   NSFetchedResultsController *transactionHistoryFetchedResultsController;
@end

@implementation AccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initializeView {
    _infoTable.tableHeaderView = self.accountHeaderView;
    _infoTable.bounces = NO;
    _infoTable.delegate = self;
    _infoTable.dataSource = self;
    _accountHeaderView.delegate = self;
    _accountHeaderView.avatarView.delegate = self;
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_ACCOUNT];
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

- (AccountHeaderView *)accountHeaderView {
    if (!_accountHeaderView) {
        self.accountHeaderView = (AccountHeaderView *)[TSTheming viewWithNibName:NSStringFromClass(AccountHeaderView.class)];
    }
    return _accountHeaderView;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactionHistoryFetchedResultsController.fetchedObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.accountInfoPrototypeCell.frame.size.height;
}

- (AccountInfoTableViewCell *)accountInfoPrototypeCell {
    if (!_accountInfoPrototypeCell) {
        self.accountInfoPrototypeCell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(AccountInfoTableViewCell.class)];
    }
    return _accountInfoPrototypeCell;
}

- (TransactionHistoryTableViewCell *)transactionHistoryPrototypeCell {
    if (!_transactionHistoryPrototypeCell) {
        self.transactionHistoryPrototypeCell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(TransactionHistoryTableViewCell.class)];
    }
    return _transactionHistoryPrototypeCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
//    cell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(AccountInfoTableViewCell.class) forIndexPath:indexPath];
    cell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(TransactionHistoryTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    AccountInfoTableViewCell *accountInfoCell = (AccountInfoTableViewCell *)cell;
    TransactionHistoryTableViewCell *historyCell = (TransactionHistoryTableViewCell *)cell;
    MOrderInfo *order = [self.transactionHistoryFetchedResultsController objectAtIndexPath:indexPath];
    NSString *productName = ((MItemInfo *)[order.items anyObject]).product.name;
    historyCell.titleLabel.text = productName.length > 0 ? productName : order.referenceNumber;
    historyCell.subtitleLabel.text = [order.orderedDate defaultStringRepresentation];
    historyCell.priceLabel.text = [NSString stringWithPrice:[order.price floatValue]];
    return;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)transactionHistoryFetchedResultsController {
    if (!_transactionHistoryFetchedResultsController) {
        NSFetchRequest *fetchRequest = [MOrderInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"status =[c] %@", MOrderInfoStatusPickedUp];
        NSSortDescriptor *sdOrderedDate = [[NSSortDescriptor alloc] initWithKey:@"orderedDate" ascending:NO];
        fetchRequest.sortDescriptors = @[sdOrderedDate];
        fetchRequest.fetchBatchSize = 20;
        self.transactionHistoryFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[AppDelegate sharedAppDelegate].managedObjectContext sectionNameKeyPath:nil cacheName:nil];  // XXX-FIX cache name
        _transactionHistoryFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_transactionHistoryFetchedResultsController performFetch:&error]) {
            DDLogError(@"error fetching transaction history: %@", error);
        }
    }
    return _transactionHistoryFetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_infoTable beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [_infoTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [_infoTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[_infoTable cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [_infoTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_infoTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_infoTable endUpdates];
}

#pragma mark - AccountHeaderViewDelegate

- (void)accountHeaderView:(AccountHeaderView *)accountHeaderView didSwitchToTableSegment:(NSInteger)segmentIndex {
}

#pragma mark - UIImagePickerControllerDelegate

- (UIImagePickerController *)avatarImagePicker {
    if (!_avatarImagePicker) {
        self.avatarImagePicker = [[UIImagePickerController alloc] init];
        _avatarImagePicker.delegate = self;
        _avatarImagePicker.allowsEditing = YES;
    }
    return _avatarImagePicker;
}

- (UIActionSheet *)imagePickerActionSheet {
    if (!_imagePickerActionSheet) {
        self.imagePickerActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:LS_CANCEL destructiveButtonTitle:nil otherButtonTitles:LS_CAMERA, LS_PHOTO_LIBRARY, nil];
    }
    return _imagePickerActionSheet;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *pickedImage = info[UIImagePickerControllerEditedImage];
    // TODO: save image to disk, generate URL, replace URL in MUserInfo, refresh avatar view
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == _imagePickerActionSheet) {
        switch (buttonIndex) {
            case 0: {  // Camera
                self.avatarImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:_avatarImagePicker animated:YES completion:nil];
            }
                break;
            case 1: {  // Photo Library
                self.avatarImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:_avatarImagePicker animated:YES completion:nil];
            }
            case 2: {  // Cancel
            }
            default:
                break;
        }
    }
}

#pragma makr - AvatarViewDelegate

- (void)avatarButtonPressedInAvatarView:(AvatarView *)avatarView {
    [self.imagePickerActionSheet showFromRect:avatarView.frame inView:_accountHeaderView animated:YES];
}

- (void)accessoryButtonPressedInAvatarView:(AvatarView *)avatarView {
}

@end
