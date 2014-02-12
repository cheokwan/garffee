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
#import "DataFetchManager.h"
#import <UIView+Helpers/UIView+Helpers.h>

@interface AccountViewController ()
@property (nonatomic, strong)   AccountInfoTableViewCell *accountInfoPrototypeCell;
@property (nonatomic, strong)   TransactionHistoryTableViewCell *transactionHistoryPrototypeCell;
@property (nonatomic, strong)   AccountInfoTableViewBalanceCell *balancePrototypeCell;
@property (nonatomic, strong)   NSFetchedResultsController *transactionHistoryFetchedResultsController;
@property (nonatomic)           BOOL isKeyboardShowing;
@property (nonatomic)           UIEdgeInsets tableViewContentInsets;
@property (nonatomic, strong)   UIResponder *activeResponder;
@property (nonatomic, strong)   UIToolbar *inputToolbar;
@property (nonatomic, strong)   UIBarButtonItem *doneButton, *cancelButton;
@property (nonatomic, strong)   UIDatePicker *birthdayDatePicker;
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
    _infoTable.delegate = self;
    _infoTable.dataSource = self;
    _accountHeaderView.delegate = self;
    _accountHeaderView.avatarView.delegate = self;
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_ACCOUNT];
    self.tableViewContentInsets = UIEdgeInsetsZero;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
    self.isKeyboardShowing = NO;
    [[DataFetchManager sharedInstance] performRestManagerFetch:@selector(fetchAppOrderHistories:) retries:3];
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

- (UIToolbar *)inputToolbar {
    if (!_inputToolbar) {
        self.inputToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
        _inputToolbar.backgroundColor = [TSTheming defaultBackgroundTransparentColor];
        self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(buttonPressed:)];
        _doneButton.tintColor = [TSTheming defaultThemeColor];
        self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(buttonPressed:)];
        _cancelButton.tintColor = [TSTheming defaultThemeColor];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self.inputToolbar setItems:@[_cancelButton, flexibleSpace, _doneButton]];
    }
    return _inputToolbar;
}

- (UIDatePicker *)birthdayDatePicker {
    if (!_birthdayDatePicker) {
        self.birthdayDatePicker = [[UIDatePicker alloc] init];
        _birthdayDatePicker.datePickerMode = UIDatePickerModeDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd MMM yyyy";
        _birthdayDatePicker.minimumDate = [dateFormatter dateFromString:@"01 Jan 1900"];
        _birthdayDatePicker.maximumDate = [NSDate date];
    }
    return _birthdayDatePicker;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    NSString *orderDetailString = [order detailString];
    historyCell.titleLabel.text = orderDetailString.length > 0 ? orderDetailString : order.referenceNumber;
    historyCell.subtitleLabel.text = [order.orderedDate defaultStringRepresentation];
    historyCell.priceLabel.text = [NSString stringWithPrice:[order.price floatValue] showFree:YES];
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
        if ([accountCell.customView isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField*)accountCell.customView;
            textField.delegate = self;
            textField.inputAccessoryView = self.inputToolbar;
            if (indexPath.row == AccountInfoTableRowsBirthday) {
                textField.inputView = self.birthdayDatePicker;
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return;
}

- (void)genderButonPressed:(id)sender {
    //do nothing if there is another field in active
    if (!_activeResponder) {
        NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
        MUserInfo *userInfo = [MUserInfo currentAppUserInfoInContext:context];
        if ([userInfo.gender isEqualToString:@"male"]) {
            userInfo.gender = @"female";
        } else if ([userInfo.gender isEqualToString:@"female"]) {
            userInfo.gender = @"male";
        } else {
            userInfo.gender = @"male";
        }
        [self markUserInfoDirtyAndSync:userInfo context:context];
        [self.infoTable reloadData];
    }
}

- (void)buttonPressed:(id)sender {
    if (sender == _doneButton) {
        if (_activeResponder && (_activeResponder.inputView == self.birthdayDatePicker)) {
            [_activeResponder resignFirstResponder];
            self.activeResponder = nil;
            NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
            MUserInfo *userInfo = [MUserInfo currentAppUserInfoInContext:context];
            userInfo.birthday = _birthdayDatePicker.date;
            [self markUserInfoDirtyAndSync:userInfo context:context];
            [self.infoTable reloadData];
        } else {
            if ([_activeResponder isKindOfClass:[UITextField class]]) {
                [self textFieldShouldReturn:(UITextField*)_activeResponder];
            }
        }
    } else if (sender == _cancelButton) {
        if (_activeResponder) {
            [_activeResponder resignFirstResponder];
            self.activeResponder = nil;
            [self.infoTable reloadData];
        }
    }
}

- (void)markUserInfoDirtyAndSync:(MUserInfo*)userInfo context:(NSManagedObjectContext *)context {
    userInfo.isDirty = @(YES);
    [context save];
    [[RestManager sharedInstance] putUserInfo:userInfo handler:self];
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL shouldBegin = YES;
    if (_activeResponder) {
        //do not allow other responders to start until current active one ends
        shouldBegin = NO;
    } else {
        self.activeResponder = textField;
        if (_activeResponder.inputView == self.birthdayDatePicker) {
            NSDate *birthday = [[AccountInfoTableManager sharedInstance] userBirthday];
            if (!birthday) {
                birthday = [NSDate date];
            }
            _birthdayDatePicker.date = birthday;
        }
        [self registerKeyboardNotifications];
    }
    return shouldBegin;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_activeResponder == textField) {
        [self commitTextFieldEditAndReturn:textField];
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.textColor = [UIColor darkTextColor];
    return YES;
}

- (void)commitTextFieldEditAndReturn:(UITextField *)textField {
    NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
    MUserInfo *userInfo = [MUserInfo currentAppUserInfoInContext:context];
    NSString *str = textField.text;
    AccountInfoTableRows infoType = [[AccountInfoTableManager sharedInstance] accountInfoTypeOfCustomView:textField];
    BOOL isValidInfo = YES;
    if (infoType != AccountInfoTableRowsNone) {
        switch (infoType) {
            case AccountInfoTableRowsName:
                if (![textField.text isEqualToString:userInfo.name]) {
                    if ((isValidInfo = [self isNameValid:str])) {
                        userInfo.isDirty = @(YES);
                        userInfo.name = str;
                    }
                }
                break;
            case AccountInfoTableRowsEmail: {
                if (![textField.text isEqualToString:userInfo.email]) {
                    if ((isValidInfo = [self isEmailValid:str])) {
                        userInfo.isDirty = @(YES);
                        userInfo.email = str;
                    }
                }
            }
                break;
            case AccountInfoTableRowsPhoneNumber: {
                if (![textField.text isEqualToString:userInfo.phoneNumber]) {
                    if ((isValidInfo = [self isPhoneValid:str])) {
                        userInfo.isDirty = @(YES);
                        userInfo.phoneNumber = str;
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    if (userInfo.isDirty) {
        [self markUserInfoDirtyAndSync:userInfo context:context];
    }
    if (isValidInfo) {
        [textField resignFirstResponder];
    } else {
        // animate an error indication
        [UIView animateWithDuration:0.8 animations:^{
            textField.textColor = [UIColor redColor];
            textField.alpha = 0.0;
            textField.alpha = 1.0;
        }];
    }
}

- (BOOL)isNameValid:(NSString *)newName {
    BOOL isValid = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
    return isValid;
}

- (BOOL)isEmailValid:(NSString *)newEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:emailRegex options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:newEmail options:0 range:NSMakeRange(0, newEmail.length)];
    return match != nil;
}

- (BOOL)isPhoneValid:(NSString *)newPhone {
    NSString *phoneRegex = @"^(\\+[\\d]+\\s*)?(\\([\\d]+\\)\\s*)?[\\d\\-]+$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:phoneRegex options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:newPhone options:0 range:NSMakeRange(0, newPhone.length)];
    return match != nil;
}

#pragma mark - UIKeyboardNotifications related
- (void)registerKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)deregisterKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    self.isKeyboardShowing = YES;
    
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (UIEdgeInsetsEqualToEdgeInsets(_tableViewContentInsets, UIEdgeInsetsZero)) {
        // if never cached the parent tableview's inset, do it now
        self.tableViewContentInsets = _infoTable.contentInset;
    }
    UIEdgeInsets newContentInsets = _tableViewContentInsets;
    newContentInsets.bottom += keyboardSize.height - 49.0;  // minus the tab bar height
    
    [UIView animateWithDuration:0.5 animations:^{
        _infoTable.contentInset = newContentInsets;
        _infoTable.scrollIndicatorInsets = newContentInsets;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!UIEdgeInsetsEqualToEdgeInsets(_tableViewContentInsets, UIEdgeInsetsZero)) {
        // if there's cached parent tableview's inset, restore it
        [UIView animateWithDuration:0.5 animations:^{
            _infoTable.contentInset = _tableViewContentInsets;
            _infoTable.scrollIndicatorInsets = _tableViewContentInsets;
        }];
    }
    _tableViewContentInsets = UIEdgeInsetsZero;
    [self deregisterKeyboardNotifications];
    self.activeResponder = nil;
    self.isKeyboardShowing = NO;
}


#pragma mark - AccountHeaderViewDelegate

- (void)accountHeaderView:(AccountHeaderView *)accountHeaderView didSwitchToTableSegment:(NSInteger)segmentIndex {
    [self.infoTable reloadData];
    [self.infoTable reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self numberOfSectionsInTableView:_infoTable])] withRowAnimation:UITableViewRowAnimationFade];  // fake some animation
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

#pragma mark - AvatarViewDelegate

- (void)avatarButtonPressedInAvatarView:(AvatarView *)avatarView {
    [self.imagePickerActionSheet showFromRect:avatarView.frame inView:_accountHeaderView animated:YES];
}

- (void)accessoryButtonPressedInAvatarView:(AvatarView *)avatarView {
}

#pragma mark - RestManagerResponseHandler
- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
    MUserInfo *mUserInfo = [MUserInfo currentAppUserInfoInContext:context];
    mUserInfo.isDirty = @(NO);
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    //XXX-ML
}

@end
