//
//  AccountViewController.h
//  ToSavour
//
//  Created by Jason Wan on 13/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountHeaderView.h"
#import "AvatarView.h"
#import "RestManager.h"

typedef enum {
    AccountViewControllerHistorySectionBalance = 0,
    AccountViewControllerHistorySectionHistory,
    AccountViewControllerHistorySectionTotal,
} AccountViewControllerHistorySection;

@interface AccountViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, AccountHeaderViewDelegate, AvatarViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, RestManagerResponseHandler>

@property (nonatomic, strong)   IBOutlet UITableView *infoTable;

@property (nonatomic, strong)   AccountHeaderView *accountHeaderView;
@property (nonatomic, strong)   UIImagePickerController *avatarImagePicker;
@property (nonatomic, strong)   UIActionSheet *imagePickerActionSheet;

@end
