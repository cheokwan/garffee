//
//  AccountViewController.h
//  ToSavour
//
//  Created by Jason Wan on 13/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountHeaderView.h"

@interface AccountViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)   IBOutlet UITableView *infoTable;
@property (nonatomic, strong)   AccountHeaderView *accountHeaderView;

@end
