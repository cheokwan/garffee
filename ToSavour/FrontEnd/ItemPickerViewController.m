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
#import "TSFrontEndIncludes.h"

typedef enum {
    ItemPickerSectionProductCategoryAndName = 0,
    ItemPickerSectionProductOptions,
    ItemPickerSectionTotal,
} ItemPickerSection;

@interface ItemPickerViewController ()
@property (nonatomic, strong) ItemPickerTableViewCell *itemPickerPrototypeCell;
@property (nonatomic, assign) UITableViewRowAnimation animationStyle;  // XXXX

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

- (void)initializeView {
    _itemTable.dataSource = self;
    _itemTable.delegate = self;
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(buttonPressed:)];  // XXXX
    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationItem.rightBarButtonItem = self.dismissButton;
    // XXXXX
    self.selectedProduct = self.allProducts[1];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {  // XXXX
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
        NSFetchRequest *fetchRequest = [MProductInfo fetchRequestInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", M_PRODUCT_INFO_TYPE_REAL];
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

- (NSArray *)optionsUnderProduct:(MProductInfo *)product {  // XXX-TEST XXXX
    return @[@[@"S1", @"S2", @"S3"],
             @[@"M1", @"M2"],
             @[@"B1", @"B2"]];
}

- (NSArray *)optionsImageUnderProduct:(MProductInfo *)product {  // XXX-TEST XXXX
    return @[@[@"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-Small-French-Fries.png", @"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-Apple-Slices.png", @"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-Side-Salad.png"],
             @[@"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-Fruit-n-Yogurt-Parfait-7-oz.png", @"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-Mighty-Wings-3-piece.png"],
             @[@"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-Minute-Maid-Orange-Juice-Small.png", @"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-Dasani-Water.png"]];
}

- (NSArray *)categoryImages {
    return @[@"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-Kiddie-Cone.png",
             @"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-Hot-Fudge-Sundae.png",
             @"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-McFlurry-with-OREO-Cookies-12-fl-oz-cup.png",
             @"http://www.mcdonalds.com/content/dam/McDonalds/item/s-mcdonalds-Chocolate-McCafe-Shake-12-fl-oz-cup.png"];
}

- (UIBarButtonItem *)dismissButton {
    if (!_dismissButton) {
        self.dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(buttonPressed:)];
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
            return self.selectedProduct.configurableOptions.count;
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
    cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ItemPickerTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ItemPickerTableViewCell *itemPickerCell = (ItemPickerTableViewCell *)cell;
    NSMutableArray *itemViews = nil;
    NSInteger defaultChoiceIndex = -1;
    switch (indexPath.section) {
        case ItemPickerSectionProductCategoryAndName: {
            itemViews = [NSMutableArray array];
            for (MProductInfo *product in self.allProducts) {
                ItemView *itemView = [[ItemView alloc] initWithText:product.name imageURL:[NSURL URLWithString:product.resolvedImageURL]];
                [itemViews addObject:itemView];
            }
        }
            break;
        case ItemPickerSectionProductOptions: {
            itemViews = [NSMutableArray array];
            MProductConfigurableOption *configurableOption = self.selectedProduct.configurableOptions[indexPath.row];
            for (MProductOptionChoice *choice in configurableOption.choices) {
                ItemView *itemView = [[ItemView alloc] initWithText:choice.name imageURL:[NSURL URLWithString:choice.resolvedImageURL]];
                [itemViews addObject:itemView];
            }
            defaultChoiceIndex = [configurableOption.defaultChoice intValue];
        }
            break;
        default:
            break;
    }
    if (itemViews) {
        for (UIView *itemView in itemViews) {
            [[NSNotificationCenter defaultCenter] addObserver:itemView selector:@selector(notificationReceived:) name:@"WakeUpBitch" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:itemView selector:@selector(notificationReceived:) name:@"SleepLaBitch" object:nil];
        }
        [itemPickerCell.pickerScrollView addItemViews:itemViews];
        itemPickerCell.pickerScrollView.occupiedIndexPath = indexPath;
        itemPickerCell.pickerScrollView.pickerDelegate = self;
        if (defaultChoiceIndex >= 0) {
            [itemPickerCell.pickerScrollView selectItemAtIndex:defaultChoiceIndex animated:NO];
        }
    }
    return;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WakeUpBitch" object:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if (!decelerate) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SleepLaBitch" object:self];
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"SleepLaBitch" object:self];
}

#pragma mark - ItemPickerScrollViewDelegate

- (void)pickerAtIndexPath:(NSIndexPath *)indexPath didSelectItem:(UIView *)itemView atIndex:(NSInteger)index {
    switch (indexPath.section) {
        case ItemPickerSectionProductCategoryAndName: {
            self.selectedProduct = self.allProducts[index];
            DDLogError(@"selected product: %@", self.selectedProduct.name);  // XXXX
            [_itemTable reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:self.animationStyle];
        }
            break;
        case ItemPickerSectionProductOptions:
            break;
        default:
            break;
    }
}

@end


@implementation ItemView

- (UILabel *)testLabelWithName:(NSString *)name {  // XXX-TEST  XXXX
    UILabel *label = [[UILabel alloc] init];
    label.contentMode = UIViewContentModeCenter;
    label.userInteractionEnabled = YES;
    label.frame = CGRectMake(10, 0, 60, 80);
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 10;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12.0];
    label.text = name;
    return label;
}

- (UIImageView *)testImageWithURL:(NSURL *)url {  // XXX-TEST XXXX
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    __weak UIImageView *weakImageView = imageView;
    [imageView setImageWithURL:url placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            CGSize scaleUpSize = CGSizeMake(weakImageView.frame.size.width * 1.5, weakImageView.frame.size.height * 1.5);
            weakImageView.image = [image resizedImageToFitInSize:scaleUpSize scaleIfSmaller:YES];
        } else {
            DDLogWarn(@"cannot set image for item: %@ - error %@", _textLabel.text, error);
        }
    }];
    return imageView;
}

- (id)initWithText:(NSString *)text imageURL:(NSURL *)imageURL {
    self = [super initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.userInteractionEnabled = YES;
    self.contentMode = UIViewContentModeCenter;
    
    if (text) {
        self.textLabel = [self testLabelWithName:text];
    }
    if (imageURL) {
        self.imageView = [self testImageWithURL:imageURL];
    }
    if (_textLabel) {
        [self addSubview:_textLabel];
    }
    if (_imageView) {
        [self addSubview:_imageView];
        _textLabel.alpha = 0.0f;
    }
    return self;
}

- (void)notificationReceived:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"WakeUpBitch"]) {
        [UIView animateWithDuration:0.5 animations:^{
            _textLabel.alpha = 1.0;
            _imageView.alpha = 0.0;
        }];
    } else if ([notification.name isEqualToString:@"SleepLaBitch"]) {
        [UIView animateWithDuration:0.5 animations:^{
            _imageView.alpha = 1.0;
            _textLabel.alpha = 0.0;
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
