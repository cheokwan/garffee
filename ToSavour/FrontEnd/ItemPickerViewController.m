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
#import "MItemSelectedOption.h"
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
@property (nonatomic, assign)   UITableViewRowAnimation animationStyle;

@property (nonatomic, strong)   ItemGridView *addItemButton;

@property (nonatomic, assign)   BOOL viewAppeared;
@property (nonatomic, strong)   NSArray *cachedSelectedItemIndexes;
@property (nonatomic, strong)   NSMutableDictionary *cachedItemViews;
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

- (NSArray *)cachedSelectedItemIndexes {
    if (!_cachedSelectedItemIndexes) {
        NSMutableArray *cache = [NSMutableArray array];
        for (NSInteger i = 0; i < self.allProducts.count; ++i) {
            [cache addObject:[NSMutableDictionary dictionary]];
        }
        self.cachedSelectedItemIndexes = cache;
    }
    return _cachedSelectedItemIndexes;
}

- (NSMutableDictionary *)cachedItemViews {
    if (!_cachedItemViews) {
        _cachedItemViews = [NSMutableDictionary dictionary];
    }
    return _cachedItemViews;
}

- (void)initializeView {
    _itemTable.dataSource = self;
    _itemTable.delegate = self;
    _itemTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _itemTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _itemTable.separatorColor = [TSTheming defaultAccentColor];
    _itemTable.backgroundColor = [TSTheming defaultContrastColor];
    _itemTable.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.itemPickerPrototypeCell.bounds.size.height, 0.0);
    
    [_itemTable addSubview:self.lineView];
    [self.view addSubview:self.boxView];
    [self.view bringSubviewToFront:self.boxView];
    
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_ORDER];
    self.navigationItem.rightBarButtonItem = self.dismissButton;
    
    if (_editingItem) {
        _defaultItem = _editingItem;
        self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_EDIT_ITEM];
    }
    NSInteger defaultProductIndex = [self.allProducts indexOfObject:_defaultItem.product];
    if (defaultProductIndex == NSNotFound) {
        defaultProductIndex = self.allProducts.count / 2;
    }
    self.selectedProduct = self.allProducts.count > defaultProductIndex ? self.allProducts[defaultProductIndex] : nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

// TODO: improve this animation code
- (void)animateChoiceSelection {
    // play selection animation
    NSMutableArray *cells = [NSMutableArray array];
    for (ItemPickerTableViewCell *cell in _itemTable.visibleCells) {
        cell.hidden = NO;
        if (cell.pickerScrollView.occupiedIndexPath.section == ItemPickerSectionProductOptions) {
            [cells addObject:cell];
        }
    }
    
    BOOL left = YES;
    NSMutableArray *directionsLeft = [NSMutableArray array];
    for (ItemPickerTableViewCell *cell in cells) {
        NSInteger selectedItemIndex = [cell.pickerScrollView getCurrentSelectedItemIndex];
        NSInteger totalNumItems = [cell.pickerScrollView getTotalNumberOfItems];
        
        if ((left && selectedItemIndex == 0) ||
            (!left && selectedItemIndex >= totalNumItems - 1)) {
            left = !left;
        }
        if (left) {
            selectedItemIndex -= 1;
        } else {
            selectedItemIndex += 1;
        }
        [directionsLeft addObject:@(left)];
        
        [cell.pickerScrollView selectItemAtIndex:selectedItemIndex animated:NO];
        
        left = !left;  // flip the direction
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        for (ItemPickerTableViewCell *cell in _itemTable.visibleCells) {
            cell.alpha = 0.0;
            cell.hidden = NO;
            cell.alpha = 1.0;
        }
    }];
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (NSInteger i = 0; i < cells.count; ++i) {
            ItemPickerTableViewCell *cell = cells[i];
            BOOL left = [directionsLeft[i] boolValue];
            
            NSInteger selectedItemIndex = [cell.pickerScrollView getCurrentSelectedItemIndex];
            // reverse animate the selection
            if (left) {
                selectedItemIndex += 1;
            } else {
                selectedItemIndex -= 1;
            }
            
            [cell.pickerScrollView selectItemAtIndex:selectedItemIndex animated:YES];
        }
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewAppeared = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self animateChoiceSelection];
        // pre-generate the checkout button table view cell
        [self tableView:_itemTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ItemPickerSectionSubmitButton]];
    });
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

- (NSInteger)selectedProductIndex {
    NSInteger index = NSNotFound;
    if (self.selectedProduct) {
        index = [self.allProducts indexOfObject:self.selectedProduct];
    }
    return index;
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
    ItemPickerTableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case ItemPickerSectionProductCategoryAndName:
            // can't do any caching of the cell manually, it's problematic
            break;
        case ItemPickerSectionProductOptions:
            // since the options cell are dynamic, we don't do caching at this point
            break;
        case ItemPickerSectionSubmitButton:
            break;
    }
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ItemPickerTableViewCell.class) forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
        if (!_viewAppeared) {
            cell.hidden = YES;
        } else {
            cell.hidden = NO;
        }
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
            if (self.cachedItemViews[indexPath]) {
                itemViews = self.cachedItemViews[indexPath];
            } else {
                itemViews = [NSMutableArray array];
                for (MProductInfo *product in self.allProducts) {
                    ItemGridView *itemView = [[ItemGridView alloc] initWithFrame:itemViewFrame text:product.name imageURL:product.URLForImageRepresentation interactable:YES shouldReceiveNotification:YES];
                    itemView.delegate = self;
                    [itemViews addObject:itemView];
                }
                self.cachedItemViews[indexPath] = itemViews;
            }
            defaultChoiceIndex = [self selectedProductIndex];
        }
            break;
        case ItemPickerSectionProductOptions: {
            MProductConfigurableOption *configurableOption = self.selectedProduct.sortedConfigurableOptions[indexPath.row];
            if (self.cachedItemViews[indexPath]) {
                itemViews = self.cachedItemViews[indexPath];
            } else {
                itemViews = [NSMutableArray array];
                for (MProductOptionChoice *choice in configurableOption.sortedOptionChoices) {
                    ItemGridView *itemView = [[ItemGridView alloc] initWithFrame:itemViewFrame text:choice.name imageURL:choice.URLForImageRepresentation interactable:YES shouldReceiveNotification:YES];
                    if ([configurableOption.sortedOptionChoices indexOfObject:choice] == [configurableOption.defaultChoice intValue]) {
                        itemView.isSuggested = YES;
                    }
                    itemView.delegate = self;
                    [itemViews addObject:itemView];
                }
                self.cachedItemViews[indexPath] = itemViews;
            }
            if ([_defaultItem.product isEqual:self.selectedProduct]) {
                // search through the default item to find a selected option choice
                for (MItemSelectedOption *selectedOption in _defaultItem.itemSelectedOptions) {
                    NSUInteger optionChoiceIndex = [configurableOption.sortedOptionChoices indexOfObject:selectedOption.productOptionChoice];
                    if (optionChoiceIndex != NSNotFound) {
                        defaultChoiceIndex = optionChoiceIndex;
                    }
                }
            }
            if (defaultChoiceIndex < 0) {
                // if no index found, use the default choice
                defaultChoiceIndex = [configurableOption.defaultChoice intValue];
            }
            
            // if there exist a cached user selected choice, takes first proiority
            NSNumber *cachedChoiceIndex = self.cachedSelectedItemIndexes[[self selectedProductIndex]][indexPath];
            if (cachedChoiceIndex) {
                defaultChoiceIndex = [cachedChoiceIndex intValue];
            }
        }
            break;
        case ItemPickerSectionSubmitButton: {
            if (self.cachedItemViews[indexPath]) {
                itemViews = self.cachedItemViews[indexPath];
            } else {
                itemViews = [NSMutableArray array];
                NSURL *imageURL = [TSTheming URLWithImageAssetNamed:@"add2cart@2x"];
                NSString *buttonTitle = _editingItem ? LS_FINISH_EDIT : LS_ADD_TO_CART;
                self.addItemButton = [[ItemGridView alloc] initWithFrame:itemViewFrame text:buttonTitle imageURL:imageURL interactable:YES shouldReceiveNotification:YES];
                _addItemButton.delegate = self;
                [itemViews addObject:_addItemButton];
                self.cachedItemViews[indexPath] = itemViews;
            }
        }
            break;
        default:
            break;
    }
    if (itemViews) {
        [itemPickerCell.pickerScrollView addItemViews:itemViews];
        itemPickerCell.pickerScrollView.occupiedIndexPath = indexPath;
        itemPickerCell.pickerScrollView.pickerDelegate = self;
        if (defaultChoiceIndex != NSNotFound && defaultChoiceIndex >= 0 && defaultChoiceIndex < itemViews.count) {
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
            for (NSIndexPath *key in self.cachedItemViews.allKeys) {
                if (key.section == ItemPickerSectionProductOptions) {
                    [self.cachedItemViews removeObjectForKey:key];
                }
            }
            [_itemTable reloadSections:[NSIndexSet indexSetWithIndex:ItemPickerSectionProductOptions] withRowAnimation:self.animationStyle];
        }
            break;
        case ItemPickerSectionProductOptions: {
            // cache the selected option
            NSInteger productIndex = [self selectedProductIndex];
            if (productIndex != NSNotFound) {
                self.cachedSelectedItemIndexes[productIndex][indexPath] = @(index);
            }
        }
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
            MProductOptionChoice *choice = configurableOption.sortedOptionChoices[choiceIndex];
            [selectedOptionChoices addObject:choice];
        }
        
        if (_editingItem) {
            // edited cart item
            [_editingItem deleteAllSelectedOptions];
            [_editingItem addOptionChoices:selectedOptionChoices];
            _editingItem.product = self.selectedProduct;
            _editingItem.productID = self.selectedProduct.id;
            if ([_delegate respondsToSelector:@selector(itemPicker:didEditItem:)]) {
                [_delegate itemPicker:self didEditItem:_editingItem];
            }
        } else {
            // add item to cart
            if ([_delegate respondsToSelector:@selector(itemPicker:didAddItem:)]) {
                MItemInfo *newItem = [MItemInfo newItemInfoWithProduct:self.selectedProduct optionChoices:selectedOptionChoices inContext:[AppDelegate sharedAppDelegate].managedObjectContext];
                [_delegate itemPicker:self didAddItem:newItem];
            }
        }
        MainTabBarController *tabBarController = [AppDelegate sharedAppDelegate].mainTabBarController;
        [tabBarController switchToTab:MainTabBarControllerTabCart animated:NO];
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
