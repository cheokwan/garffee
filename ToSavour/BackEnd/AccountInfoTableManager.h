//
//  AccountInfoTableManager.h
//  ToSavour
//
//  Created by LAU Leung Yan on 26/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

// Subject to be confirmed

typedef NS_ENUM(NSInteger, AccountInfoTableSections) {
    AccountInfoTableSectionsBalance = 0,
    AccountInfoTableSectionsUserInfo,
    AccountInfoTableSectionsCount
};

typedef NS_ENUM(NSInteger, AccountInfoTableRows) {
    //subject to be finalized
    AccountInfoTableRowsName = 0,
    AccountInfoTableRowsEmail,
    AccountInfoTableRowsGender,
    AccountInfoTableRowsBirthday,
    AccountInfoTableRowsPhoneNumber,
//    AccountInfoTableRowsFacebookId,
//    AccountInfoTableRowsUserType,
    AccountInfoTableRowsCount,
    AccountInfoTableRowsNone
};

#import <Foundation/Foundation.h>

#import "MUserInfo.h"

@interface AccountInfoTableManager : NSObject

@property (nonatomic, strong) MUserInfo *user;

+ (AccountInfoTableManager *)sharedInstance;

- (int)numberOfSections;
- (int)numberOfRows:(int)section;

//  return nil if N/A
- (UIImage *)cellImageForIndexPath:(NSIndexPath *)indexPath;

//  return empty string if N/A
- (NSString *)cellLabelTextForIndexPath:(NSIndexPath *)indexPath;

//  return nil if N/A
- (UIView *)accessoryViewForIndexPath:(NSIndexPath *)indexPath taget:(id)target action:(SEL)action;

// return AccountInfoTableRowsNone if N/A
- (AccountInfoTableRows)accountInfoTypeOfCustomView:(UIView *)view;

- (NSString *)balanceString;
- (NSDate *)userBirthday;

@end
