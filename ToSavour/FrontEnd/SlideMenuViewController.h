//
//  SlideMenuViewController.h
//  ToSavour
//
//  Created by Jason Wan on 21/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#include "RestManager.h"

@interface SlideMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate, NSFetchedResultsControllerDelegate, RestManagerResponseHandler>

@property (nonatomic, strong)   IBOutlet UITableView *tableView;

@end
