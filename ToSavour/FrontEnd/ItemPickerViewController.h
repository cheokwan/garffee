//
//  ItemPickerViewController.h
//  ToSavour
//
//  Created by Jason Wan on 7/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemPickerScrollView.h"
#import "ItemGridView.h"
@class MProductInfo;
@class MItemInfo;
@class ItemPickerViewController;

@protocol ItemPickerViewControllerDelegate <NSObject>
- (void)itemPicker:(ItemPickerViewController *)itemPicker didAddItem:(MItemInfo *)item;
@end

@interface ItemPickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ItemPickerScrollViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate, ItemGridViewDelegate>

@property (nonatomic, strong)   IBOutlet UITableView *itemTable;
@property (nonatomic, strong)   NSArray *allProducts;   // MProductInfo
@property (nonatomic, strong)   NSArray *allCategories; // NSString
@property (nonatomic, strong)   MProductInfo *selectedProduct;
@property (nonatomic, strong)   UIBarButtonItem *dismissButton;

@property (nonatomic, weak)     id<ItemPickerViewControllerDelegate> delegate;
@property (nonatomic, strong)   MItemInfo *defaultItem;

@end
