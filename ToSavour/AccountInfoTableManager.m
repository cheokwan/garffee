//
//  AccountInfoTableManager.m
//  ToSavour
//
//  Created by LAU Leung Yan on 26/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "AccountInfoTableManager.h"
#import <UIView+Helpers/UIView+Helpers.h>
#import "NSString+Helper.h"

@interface AccountInfoTableManager ()
@property (nonatomic, strong) NSDateFormatter *birthdayFormatter;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *birthdayTextField;
@property (nonatomic, strong) UITextField *phoneNumberTextField;
@end

@implementation AccountInfoTableManager

static AccountInfoTableManager *instance = nil;

+ (AccountInfoTableManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AccountInfoTableManager alloc] init];
    });
    return instance;
}

- (int)numberOfSections {
    return AccountInfoTableSectionsCount;
}

- (int)numberOfRows:(int)section {
    int numberOfRows = 0;
    if (section == AccountInfoTableSectionsBalance) {
        numberOfRows = 1;
    } else if (section == AccountInfoTableSectionsUserInfo) {
        numberOfRows = AccountInfoTableRowsCount;
    }
    return numberOfRows;
}

- (UIImage *)cellImageForIndexPath:(NSIndexPath *)indexPath {
    NSString *imageName = nil;
    switch (indexPath.row) {
        case AccountInfoTableRowsName:
            imageName = @"ico_profile_name";
            break;
        case AccountInfoTableRowsEmail:
            imageName = @"ico_profile_email";
            break;
        case AccountInfoTableRowsGender:
            imageName = @"ico_profile_sex";
            break;
        case AccountInfoTableRowsBirthday:
            imageName = @"ico_profile_birth";
            break;
        case AccountInfoTableRowsPhoneNumber:
            imageName = @"ico_profile_phone";
            break;
        default:
            break;
    }
    UIImage *image = imageName ? [UIImage imageNamed:imageName] : nil;
    return image;
}

- (NSString *)cellLabelTextForIndexPath:(NSIndexPath *)indexPath {
    NSString *text = @"";
    if (indexPath.section == AccountInfoTableSectionsBalance) {
        text = LS_BALANCE;
    } else if (indexPath.section == AccountInfoTableSectionsUserInfo) {
        switch (indexPath.row) {
            case AccountInfoTableRowsName:
                text = LS_NAME;
                break;
            case AccountInfoTableRowsEmail:
                text = LS_EMAIL;
                break;
            case AccountInfoTableRowsGender:
                text = LS_SEX;
                break;
            case AccountInfoTableRowsBirthday:
                text = LS_BIRTHDAY;
                break;
            case AccountInfoTableRowsPhoneNumber:
                text = LS_PHONE;
                break;
            default:
                break;
        }
    }
    return text;
}

- (UIView *)accessoryViewForIndexPath:(NSIndexPath *)indexPath taget:(id)target action:(SEL)action {
    UIView *view = nil;
    if (indexPath.section == AccountInfoTableSectionsUserInfo) {
        switch (indexPath.row) {
            case AccountInfoTableRowsName: {
                self.nameTextField.text = self.user.name;
                view = self.nameTextField;
            }
                break;
            case AccountInfoTableRowsEmail: {
                self.emailTextField.text = self.user.email;
                view = self.emailTextField;
            }
                break;
            case AccountInfoTableRowsGender: {
                UIView *aView = [self genderView];
                //add a button on it
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, 0, aView.frameSizeWidth, aView.frameSizeHeight);
                [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                [aView addSubview:button];
                view = aView;
            }
                break;
            case AccountInfoTableRowsBirthday: {
                self.birthdayTextField.text = [self.birthdayFormatter stringFromDate:self.user.birthday];
                view = self.birthdayTextField;
            }
                break;
            case AccountInfoTableRowsPhoneNumber: {
                self.phoneNumberTextField.text = self.user.phoneNumber;
                view = self.phoneNumberTextField;
            }
                break;
            default:
                break;
        }
    }
    return view;
}

- (NSString *)balanceString {
    return [NSString stringWithPrice:[self.user.creditBalance floatValue]];
}

#pragma marks - Accessory views
- (UITextField *)nameTextField {
    if (!_nameTextField) {
        self.nameTextField = [self textFieldWithProperties];
        _nameTextField.placeholder = LS_NAME;
    }
    return _nameTextField;
}

- (UITextField *)emailTextField {
    if (!_emailTextField) {
        self.emailTextField = [self textFieldWithProperties];
        _emailTextField.placeholder = LS_EMAIL;
    }
    return _emailTextField;
}

- (UITextField *)birthdayTextField {
    if (!_birthdayTextField) {
        self.birthdayTextField = [self textFieldWithProperties];
        _birthdayTextField.placeholder = LS_BIRTHDAY;
    }
    return _birthdayTextField;
}

- (UITextField *)phoneNumberTextField {
    if (!_phoneNumberTextField) {
        self.phoneNumberTextField = [self textFieldWithProperties];
        _phoneNumberTextField.placeholder = LS_PHONE;
    }
    return _phoneNumberTextField;
}

- (UITextField *)textFieldWithProperties {
    UITextField *textField = [[UITextField alloc] init];
    textField.textAlignment = NSTextAlignmentRight;
    textField.frame = CGRectMake(0, 0, 160, 37);
    return textField;
}

- (UIView *)genderView {
    CGRect rect = CGRectMake(0, 0, 82, 31);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    UIImageView *sexOffImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_sex_off"]];
    sexOffImageView.frame = rect;
    [view addSubview:sexOffImageView];
    
    NSString *genderImageString = nil;
    if ([self.user.gender isEqualToString:@"male"]) {
        genderImageString = @"btn_sex_m";
    } else if ([self.user.gender isEqualToString:@"female"]) {
        genderImageString = @"btn_sex_f";
    }
    if (genderImageString) {
        UIImageView *genderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:genderImageString]];
        genderImageView.frame = rect;
        [view addSubview:genderImageView];
    }
    return view;
}

#pragma marks - setters/getters
- (NSDateFormatter *)birthdayFormatter {
    if (!_birthdayFormatter) {
        self.birthdayFormatter = [[NSDateFormatter alloc] init];
        _birthdayFormatter.dateFormat = @"dd MMM yyyy";
    }
    return _birthdayFormatter;
}

- (MUserInfo *)user {
    if (!_user) {
        self.user = [MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    }
    return _user;
}

@end
