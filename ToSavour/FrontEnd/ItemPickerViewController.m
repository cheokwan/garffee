//
//  ItemPickerViewController.m
//  ToSavour
//
//  Created by Jason Wan on 7/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "ItemPickerViewController.h"
#import "ItemPickerTableViewCell.h"
#import "ItemPickerScrollView.h"
#import "AppDelegate.h"
#import "NSManagedObject+Helper.h"
#import "MProductInfo.h"
#import "MProductConfigurableOption.h"
#import "MProductOptionChoice.h"
#import "MItemInfo.h"
#import "MGlobalConfiguration.h"
#import "TSFrontEndIncludes.h"
#import "ItemGridView.h"

typedef enum {
    ItemPickerSectionProductCategoryAndName = 0,
    ItemPickerSectionProductOptions,
    ItemPickerSectionSubmitButton,
    ItemPickerSectionTotal,
} ItemPickerSection;

@interface ItemPickerViewController ()
@property (nonatomic, strong)   ItemPickerTableViewCell *itemPickerPrototypeCell;
@property (nonatomic, assign)   UITableViewRowAnimation animationStyle;  // XXX-TEST

@property (nonatomic, strong)   ItemPickerTableViewCell *cachedProductCategoryAndNameCell;
@property (nonatomic, strong)   ItemPickerTableViewCell *cachedSubmitButtonCell;
@property (nonatomic, strong)   ItemGridView *addItemButton;

@end

@implementation ItemPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIView *)lineView {
    static UIView *line = nil;
    if (!line) {
        line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _itemTable.bounds.size.width, 1)];
        line.backgroundColor = [TSTheming defaultThemeColor];
    }
    return line;
}

- (UIView *)boxView {
    static UIView *box = nil;
    if (!box) {
        CGRect boxFrame = CGRectMake(0.0, 65.0, self.itemPickerPrototypeCell.pickerScrollView.itemViewDimension, self.view.bounds.size.height - 65.0);
        box = [[UIView alloc] initWithFrame:boxFrame];
        box.center = CGPointMake(self.view.bounds.size.width / 2.0, box.center.y);
        box.backgroundColor = [UIColor clearColor];
        box.layer.borderColor = [[TSTheming defaultAccentColor] CGColor];
        box.layer.borderWidth = 1.0;
        box.userInteractionEnabled = NO;
    }
    return box;
}

- (void)initializeView {
    _itemTable.dataSource = self;
    _itemTable.delegate = self;
    _itemTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _itemTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _itemTable.separatorColor = [TSTheming defaultAccentColor];
    _itemTable.backgroundColor = [TSTheming defaultContrastColor];
    
    [_itemTable addSubview:self.lineView];
    [self.view addSubview:self.boxView];
    [self.view bringSubviewToFront:self.boxView];
    
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_ORDER];
    self.navigationItem.rightBarButtonItem = self.dismissButton;
    NSInteger defaultProductIndex = [self.allProducts indexOfObject:_defaultProduct];
    if (defaultProductIndex == NSNotFound) {
        defaultProductIndex = self.allProducts.count / 2;
    }
    self.selectedProduct = self.allProducts.count > 0 ? self.allProducts[defaultProductIndex] : nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonPressed:(id)sender {
    if (sender == _dismissButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (sender == self.navigationItem.leftBarButtonItem) {
        UIAlertView *picker = [[UIAlertView alloc] initWithTitle:nil message:@"Choose your animation style" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Fade", @"Right", @"Left", @"Top", @"Bottom", @"None", @"Middle", @"Automatic", nil];
        [picker show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            self.animationStyle = UITableViewRowAnimationFade;
            break;
        case 2:
            self.animationStyle = UITableViewRowAnimationRight;
            break;
        case 3:
            self.animationStyle = UITableViewRowAnimationLeft;
            break;
        case 4:
            self.animationStyle = UITableViewRowAnimationTop;
            break;
        case 5:
            self.animationStyle = UITableViewRowAnimationBottom;
            break;
        case 6:
            self.animationStyle = UITableViewRowAnimationNone;
            break;
        case 7:
            self.animationStyle = UITableViewRowAnimationMiddle;
            break;
        case 8:
            self.animationStyle = UITableViewRowAnimationAutomatic;
            break;
        default:
            break;
    }
}

- (NSArray *)allCategories {
    if (!_allCategories && self.allProducts.count != 0) {
        NSMutableSet *categories = [NSMutableSet set];
        for (MProductInfo *product in self.allProducts) {
            [categories addObject:product.category];
        }
        self.allCategories = [categories allObjects];
    }
    return _allCategories;
}

- (NSArray *)allProducts {
    if (!_allProducts) {
        NSFetchRequest *fetchRequest = [MProductInfo fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type =[c] %@", MProductInfoTypeReal];
        fetchRequest.predicate = predicate;
        NSError *error = nil;
        self.allProducts = [[AppDelegate sharedAppDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (_allProducts.count == 0 || error) {
            DDLogError(@"unable to fetch root products info: %@", error);
        }
    }
    return _allProducts;
}

- (NSArray *)productsUnderCategory:(NSString *)category {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category = %@", category];
    return [self.allProducts filteredArrayUsingPredicate:predicate];
}

- (UIBarButtonItem *)dismissButton {
    if (!_dismissButton) {
        self.dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ico_close"] style:UIBarButtonItemStylePlain target:self action:@selector(buttonPressed:)];
        _dismissButton.tintColor = [TSTheming defaultAccentColor];
    }
    return _dismissButton;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ItemPickerSectionTotal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case ItemPickerSectionProductCategoryAndName:
            return 1;
            break;
        case ItemPickerSectionProductOptions:
            return self.selectedProduct.sortedConfigurableOptions.count;
            break;
        case ItemPickerSectionSubmitButton:
            return 1;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemPickerPrototypeCell.bounds.size.height;
}

- (ItemPickerTableViewCell *)itemPickerPrototypeCell {
    if (!_itemPickerPrototypeCell) {
        self.itemPickerPrototypeCell = (ItemPickerTableViewCell *)[_itemTable dequeueReusableCellWithIdentifier:NSStringFromClass(ItemPickerTableViewCell.class)];
    }
    return _itemPickerPrototypeCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case ItemPickerSectionProductCategoryAndName:
            cell = _cachedProductCategoryAndNameCell;
            break;
        case ItemPickerSectionProductOptions:
            // since the options cell are dynamic, we don't do caching at this point
            break;
        case ItemPickerSectionSubmitButton:
            cell = _cachedSubmitButtonCell;
            break;
    }
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ItemPickerTableViewCell.class) forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ItemPickerTableViewCell *itemPickerCell = (ItemPickerTableViewCell *)cell;
    NSMutableArray *itemViews = nil;
    NSInteger defaultChoiceIndex = -1;
    CGRect itemViewFrame = CGRectMake(0, 0, itemPickerCell.pickerScrollView.itemViewDimension, itemPickerCell.pickerScrollView.itemViewDimension);
    switch (indexPath.section) {
        case ItemPickerSectionProductCategoryAndName: {
            itemViews = [NSMutableArray array];
            for (MProductInfo *product in self.allProducts) {
                ItemGridView *itemView = [[ItemGridView alloc] initWithFrame:itemViewFrame text:product.name imageURL:product.URLForImageRepresentation interactable:YES shouldReceiveNotification:YES];
                itemView.delegate = self;
                [itemViews addObject:itemView];
            }
            defaultChoiceIndex = [self.allProducts indexOfObject:self.selectedProduct];
            self.cachedProductCategoryAndNameCell = itemPickerCell;
        }
            break;
        case ItemPickerSectionProductOptions: {
            itemViews = [NSMutableArray array];
            MProductConfigurableOption *configurableOption = self.selectedProduct.sortedConfigurableOptions[indexPath.row];
            for (MProductOptionChoice *choice in configurableOption.choices) {
                ItemGridView *itemView = [[ItemGridView alloc] initWithFrame:itemViewFrame text:choice.name imageURL:choice.URLForImageRepresentation interactable:YES shouldReceiveNotification:YES];
                itemView.delegate = self;
                [itemViews addObject:itemView];
            }
            defaultChoiceIndex = [configurableOption.defaultChoice intValue];
        }
            break;
        case ItemPickerSectionSubmitButton: {
            itemViews = [NSMutableArray array];
            NSURL *imageURL = [NSURL URLWithString:[[MGlobalConfiguration cachedBlobHostName] stringByAppendingPathComponent:@"productimages/cup_1.png"]];  // TODO: should we get some other image?
            self.addItemButton = [[ItemGridView alloc] initWithFrame:itemViewFrame text:LS_ADD_TO_CART imageURL:imageURL interactable:YES shouldReceiveNotification:YES];
            _addItemButton.delegate = self;
            [itemViews addObject:_addItemButton];
            self.cachedSubmitButtonCell = itemPickerCell;
        }
            break;
        default:
            break;
    }
    if (itemViews) {
        [itemPickerCell.pickerScrollView addItemViews:itemViews];
        itemPickerCell.pickerScrollView.occupiedIndexPath = indexPath;
        itemPickerCell.pickerScrollView.pickerDelegate = self;
        if (defaultChoiceIndex >= 0 && defaultChoiceIndex != NSNotFound) {
            [itemPickerCell.pickerScrollView selectItemAtIndex:defaultChoiceIndex animated:NO];
        }
    }
    return;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:ItemGridViewDragTransitionNotificationStart object:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if (!decelerate) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ItemGridViewDragTransitionNotificationStop object:self];
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [[NSNotificationCenter defaultCenter] postNotificationName:ItemGridViewDragTransitionNotificationStop object:self];
}

#pragma mark - ItemPickerScrollViewDelegate

- (void)pickerAtIndexPath:(NSIndexPath *)indexPath didSelectItem:(UIView *)itemView atIndex:(NSInteger)index {
    switch (indexPath.section) {
        case ItemPickerSectionProductCategoryAndName: {
            self.selectedProduct = self.allProducts[index];
            [_itemTable reloadSections:[NSIndexSet indexSetWithIndex:ItemPickerSectionProductOptions] withRowAnimation:self.animationStyle];
        }
            break;
        case ItemPickerSectionProductOptions:
            break;
        default:
            break;
    }
}

#pragma mark - ItemGridViewDelegate

- (void)itemGridViewButtonDidPressed:(ItemGridView *)itemGridView {
    if (itemGridView == _addItemButton) {
        // count all the selected option choices
        NSMutableArray *selectedOptionChoices = [NSMutableArray array];
        for (NSInteger row = 0; row < [self.itemTable numberOfRowsInSection:ItemPickerSectionProductOptions]; ++row) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:ItemPickerSectionProductOptions];
            ItemPickerTableViewCell *itemPickerCell = (ItemPickerTableViewCell *)[self.itemTable cellForRowAtIndexPath:indexPath];
            NSInteger choiceIndex = [itemPickerCell.pickerScrollView getCurrentSelectedItemIndex];
            MProductConfigurableOption *configurableOption = self.selectedProduct.sortedConfigurableOptions[row];
            MProductOptionChoice *choice = configurableOption.choices[choiceIndex];
            [selectedOptionChoices addObject:choice];
        }
        
        // add item to cart
        if ([_delegate respondsToSelector:@selector(itemPicker:didAddItem:)]) {
            MItemInfo *newItem = [MItemInfo newItemInfoWithProduct:self.selectedProduct optionChoices:selectedOptionChoices inContext:[AppDelegate sharedAppDelegate].managedObjectContext];
            [_delegate itemPicker:self didAddItem:newItem];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        ItemPickerScrollView *pickerScrollView = nil;
        if ([itemGridView.superview isKindOfClass:ItemPickerScrollView.class]) {
            pickerScrollView = (ItemPickerScrollView *)itemGridView.superview;
        }
        [pickerScrollView selectItem:itemGridView animated:YES];
    }
}

@end
