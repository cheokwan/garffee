//
//  ItemPickerViewController.h
//  ToSavour
//
//  Created by Jason Wan on 7/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemPickerTableViewCell.h"

@interface ItemPickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)   IBOutlet UITableView *itemTable;
@property (nonatomic, strong)   NSMutableArray *rootItems;

@end
