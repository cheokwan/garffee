//
//  SettingsViewController.h
//  ToSavour
//
//  Created by Jason Wan on 17/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SettingsSectionSwitches = 0,
    SettingsSectionPages,
    SettingsSectionPicker,
    SettingsSectionDestructive,
    SettingsSectionTotal,
} SettingsSection;

typedef enum {
    SettingsSectionSwitchesCellPushNotifications = 0,
    SettingsSectionSwitchesCellReceiveAlerts,
    SettingsSectionSwitchesCellTotal,
} SettingsSectionSwitchesCell;

typedef enum {
    SettingsSectionPagesCellAboutUs = 0,
    SettingsSectionPagesCellTermsOfService,
    SettingsSectionPagesCellPrivacyPolicy,
    SettingsSectionPagesCellFAQ,
    SettingsSectionPagesCellDebug,
    SettingsSectionPagesCellTotal,
} SettingsSectionPagesCell;

typedef enum {
    SettingsSectionPickerCellLanguage = 0,
    SettingsSectionPickerCellTotal,
} SettingsSectionPickerCell;

typedef enum {
    SettingsSectionDestructiveCellLogout = 0,
    SettingsSectionDestructiveCellTotal,
} SettingsSectionDestructiveCell;


@interface SettingsViewController : UITableViewController

@property (nonatomic, strong)   IBOutlet UITableViewCell *pushNotificationSwitchCell;
@property (nonatomic, strong)   IBOutlet UITableViewCell *alertSwitchCell;

@property (nonatomic, strong)   IBOutlet UITableViewCell *aboutUsCell;
@property (nonatomic, strong)   IBOutlet UITableViewCell *termsOfServiceCell;
@property (nonatomic, strong)   IBOutlet UITableViewCell *privacyPolicyCell;
@property (nonatomic, strong)   IBOutlet UITableViewCell *faqCell;
@property (nonatomic, strong)   IBOutlet UITableViewCell *debugCell;

@property (nonatomic, strong)   IBOutlet UITableViewCell *languageSelectionCell;

@property (nonatomic, strong)   IBOutlet UITableViewCell *logoutCell;

@end
