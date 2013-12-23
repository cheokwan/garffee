//
//  CartViewController.h
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartHeaderView.h"
#import "RestManager.h"

@interface CartViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, RestManagerResponseHandler>

@property (nonatomic, strong)   IBOutlet UITableView *itemList;
@property (nonatomic, strong)   IBOutlet CartHeaderView *cartHeaderView;
@property (nonatomic, strong)   UIBarButtonItem *addOrderButton;

@end
