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
#import "AccountInfoTableViewBalanceCell.h"
#import "TSFrontEndIncludes.h"
#import "MOrderInfo.h"
#import "MItemInfo.h"
#import "MProductInfo.h"
#import "AccountInfoTableManager.h"
#import <UIView+Helpers/UIView+Helpers.h>

@interface AccountViewController ()
@property (nonatomic, strong)   AccountInfoTableViewCell *accountInfoPrototypeCell;
@property (nonatomic, strong)   TransactionHistoryTableViewCell *transactionHistoryPrototypeCell;
@property (nonatomic, strong)   AccountInfoTableViewBalanceCell *balancePrototypeCell;
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

- (UISegmentedControl *)tableSwitcher {
    return self.accountHeaderView.tableSwitcher;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSection = 1;
    if ([self tableSwitcher].selectedSegmentIndex == SegmentIndexAccountInfo) {
        numberOfSection = [[AccountInfoTableManager sharedInstance] numberOfSections];
    }
    return numberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if ([self tableSwitcher].selectedSegmentIndex == SegmentIndexOrderHistories) {
        numberOfRows = self.transactionHistoryFetchedResultsController.fetchedObjects.count;
    } else if ([self tableSwitcher].selectedSegmentIndex == SegmentIndexAccountInfo) {
        numberOfRows = [[AccountInfoTableManager sharedInstance] numberOfRows:section];
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    if ([self tableSwitcher].selectedSegmentIndex == SegmentIndexOrderHistories) {
        height = self.transactionHistoryPrototypeCell.frameSizeHeight;
    } else if ([self tableSwitcher].selectedSegmentIndex == SegmentIndexAccountInfo) {
        if (indexPath.section == AccountInfoTableSectionsBalance) {
            height = self.balancePrototypeCell.frameSizeHeight;
        } else if (indexPath.section == AccountInfoTableSectionsUserInfo) {
            height = self.accountInfoPrototypeCell.frameSizeHeight;
        }
    }
    return height;
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

- (AccountInfoTableViewBalanceCell *)balancePrototypeCell {
    if (!_balancePrototypeCell) {
        self.balancePrototypeCell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(AccountInfoTableViewBalanceCell.class)];
    }
    return _balancePrototypeCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([self tableSwitcher].selectedSegmentIndex == SegmentIndexOrderHistories) {
        cell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(TransactionHistoryTableViewCell.class) forIndexPath:indexPath];
    } else if ([self tableSwitcher].selectedSegmentIndex == SegmentIndexAccountInfo) {
        if (indexPath.section == AccountInfoTableSectionsBalance) {
            cell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(AccountInfoTableViewBalanceCell.class) forIndexPath:indexPath];
        } else if (indexPath.section == AccountInfoTableSectionsUserInfo) {
            cell = [_infoTable dequeueReusableCellWithIdentifier:NSStringFromClass(AccountInfoTableViewCell.class) forIndexPath:indexPath];
        }
        
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([self tableSwitcher].selectedSegmentIndex == SegmentIndexOrderHistories) {
        [self configureHistoryCell:(TransactionHistoryTableViewCell*)cell atIndexPath:indexPath];
    } else if ([self tableSwitcher].selectedSegmentIndex == SegmentIndexAccountInfo) {
        [self configureAccountCell:cell atIndexPath:indexPath];
    }
    return;
}

- (void)configureHistoryCell:(TransactionHistoryTableViewCell *)historyCell atIndexPath:(NSIndexPath *)indexPath {
    MOrderInfo *order = [self.transactionHistoryFetchedResultsController objectAtIndexPath:indexPath];
    NSString *productName = ((MItemInfo *)[order.items anyObject]).product.name;
    historyCell.titleLabel.text = productName.length > 0 ? productName : order.referenceNumber;
    historyCell.subtitleLabel.text = [order.orderedDate defaultStringRepresentation];
    historyCell.priceLabel.text = [NSString stringWithPrice:[order.price floatValue]];
    return;
}

- (void)configureAccountCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == AccountInfoTableSectionsBalance) {
        AccountInfoTableViewBalanceCell *balanceCell = (AccountInfoTableViewBalanceCell*)cell;
        balanceCell.balanceStringLabel.text = LS_BALANCE;
        balanceCell.balanceStringLabel.textColor = [TSTheming defaultThemeColor];
        balanceCell.balance.text = [[AccountInfoTableManager sharedInstance] balanceString];
    } else if (indexPath.section == AccountInfoTableSectionsUserInfo) {
        AccountInfoTableViewCell *accountCell = (AccountInfoTableViewCell*)cell;
        accountCell.imageView.image = [[AccountInfoTableManager sharedInstance] cellImageForIndexPath:indexPath];
        accountCell.titleLabel.text = [[AccountInfoTableManager sharedInstance] cellLabelTextForIndexPath:indexPath];
        accountCell.customView = [[AccountInfoTableManager sharedInstance] accessoryViewForIndexPath:indexPath taget:self action:@selector(genderButonPressed:)];
        CGRect customViewRect = accountCell.customView.frame;
        float padding = 10.0f;
        customViewRect.origin.x = accountCell.frameSizeWidth - padding - customViewRect.size.width;
        customViewRect.origin.y = accountCell.frameSizeHeight / 2 - customViewRect.size.height / 2;
        accountCell.customView.frame = customViewRect;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return;
}

- (void)genderButonPressed:(id)sender {
    NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
    MUserInfo *userInfo = [MUserInfo currentAppUserInfoInContext:context];
    if ([userInfo.gender isEqualToString:@"male"]) {
        userInfo.gender = @"female";
    } else if ([userInfo.gender isEqualToString:@"female"]) {
        userInfo.gender = @"male";
    } else {
        userInfo.gender = @"male";
    }
    [context save];
    [self.infoTable reloadData];
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
    [self.infoTable reloadData];
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
