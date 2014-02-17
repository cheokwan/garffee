//
//  SettingsViewController.m
//  ToSavour
//
//  Created by Jason Wan on 17/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "SettingsViewController.h"
#import "TutorialLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import "TSFrontEndIncludes.h"
#import "TSModelIncludes.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface SettingsViewController ()
@property (nonatomic, strong)   UIAlertView *logoutAlertView;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initializeView {
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_SETTINGS];
    
    _pushNotificationSwitchCell.textLabel.text = LS_PUSH_NOTIFICATIONS;
    _pushNotificationSwitchCell.detailTextLabel.text = nil;
    _pushNotificationSwitchCell.accessoryView = [[UISwitch alloc] init];
    
    _alertSwitchCell.textLabel.text = LS_RECEIVE_ALERTS;
    _alertSwitchCell.detailTextLabel.text = nil;
    _alertSwitchCell.accessoryView = [[UISwitch alloc] init];
    
    _aboutUsCell.textLabel.text = LS_ABOUT_US;
    _aboutUsCell.detailTextLabel.text = nil;
    _aboutUsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _termsOfServiceCell.textLabel.text = LS_TERMS_OF_SERVICE;
    _termsOfServiceCell.detailTextLabel.text = nil;
    _termsOfServiceCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _privacyPolicyCell.textLabel.text = LS_PRIVACY_POLICY;
    _privacyPolicyCell.detailTextLabel.text = nil;
    _privacyPolicyCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _faqCell.textLabel.text = LS_FAQ;
    _faqCell.detailTextLabel.text = nil;
    _faqCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _debugCell.textLabel.text = LS_DEBUG;
    _debugCell.detailTextLabel.text = nil;
    _debugCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _languageSelectionCell.textLabel.text = LS_LANGUAGE;
    _languageSelectionCell.detailTextLabel.text = @"English";
    _languageSelectionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _logoutCell.textLabel.text = LS_LOGOUT;
    _logoutCell.detailTextLabel.text = nil;
    _logoutCell.textLabel.textColor = [UIColor redColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == SettingsSectionSwitches) {
    } else if (indexPath.section == SettingsSectionPages) {
    } else if (indexPath.section == SettingsSectionPicker) {
    } else if (indexPath.section == SettingsSectionDestructive) {
        if (indexPath.row == SettingsSectionDestructiveCellLogout) {
            RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:LS_CANCEL];
            [cancelButton setAction:^{
                self.logoutAlertView = nil;
            }];
            RIButtonItem *confirmButton = [RIButtonItem itemWithLabel:LS_CONFIRM];
            [confirmButton setAction:^{
                MBProgressHUD *spinner = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                spinner.mode = MBProgressHUDModeIndeterminate;
                spinner.labelText = LS_LOGGING_OUT;
                spinner.detailsLabelText = LS_PLEASE_WAIT;
                
                // nuke the database
                NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
                [MUserInfo removeALlObjectsInContext:context];
                [MProductInfo removeALlObjectsInContext:context];
                [MProductConfigurableOption removeALlObjectsInContext:context];
                [MProductOptionChoice removeALlObjectsInContext:context];
                [MOrderInfo removeALlObjectsInContext:context];
                [MItemInfo removeALlObjectsInContext:context];
                [MItemSelectedOption removeALlObjectsInContext:context];
                [MCouponInfo removeALlObjectsInContext:context];
                [MGlobalConfiguration removeALlObjectsInContext:context];
                [MBranch removeALlObjectsInContext:context];
                [context saveToPersistentStore];
                // clear facebook session
                [[FBSession activeSession] closeAndClearTokenInformation];
                
                [spinner hide:YES];
                
                TutorialLoginViewController *tutorialLoginViewController = (TutorialLoginViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(TutorialLoginViewController.class)];
                tutorialLoginViewController.skipTutorial = YES;
                tutorialLoginViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:tutorialLoginViewController animated:YES completion:nil];
                self.logoutAlertView = nil;
            }];
            self.logoutAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to logout?", @"") message:nil cancelButtonItem:cancelButton otherButtonItems:confirmButton, nil];
            [_logoutAlertView show];
        }
    }
}

@end
