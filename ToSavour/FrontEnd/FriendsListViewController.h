//
//  FriendsListViewController.h
//  ToSavour
//
//  Created by Jason Wan on 12/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FriendsListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong)   IBOutlet UITableView *friendsList;

@end
