//
//  ItemPickerViewController.h
//  ToSavour
//
//  Created by Jason Wan on 7/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemPickerTableViewCell.h"
@class MProductInfo;

@interface ItemPickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ItemPickerScrollViewDelegate, /*XXXX*/UIAlertViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong)   IBOutlet UITableView *itemTable;
@property (nonatomic, strong)   NSArray *allProducts;   // MProductInfo
@property (nonatomic, strong)   NSArray *allCategories; // NSString
@property (nonatomic, strong)   MProductInfo *selectedProduct;
@property (nonatomic, strong)   UIBarButtonItem *dismissButton;

@end


@interface ItemView : UIView
@property (nonatomic, strong)   UILabel *textLabel;
@property (nonatomic, strong)   UIImageView *imageView;

- (id)initWithText:(NSString *)text imageURL:(NSURL *)imageURL;
- (void)notificationReceived:(NSNotification *)notification;
@end