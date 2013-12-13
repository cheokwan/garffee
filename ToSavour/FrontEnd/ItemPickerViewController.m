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

@interface ItemPickerViewController ()
@property (nonatomic, strong) ItemPickerTableViewCell *itemPickerPrototypeCell;
@property (nonatomic, readonly) CGFloat itemViewDimension;
@property (nonatomic, readonly) CGFloat itemViewEmptyOffsetX;

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

- (NSArray *)rootItems {
    if (!_rootItems) {
        self.rootItems = [NSMutableArray array];
        for (int i = 0; i < 10; ++i) {
            UILabel *label = [[UILabel alloc] init];
            label.contentMode = UIViewContentModeCenter;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [NSString stringWithFormat:@"%d", i];
            [_rootItems addObject:label];
        }
    }
    return _rootItems;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
    [itemPickerCell.pickerScrollView addItemViews:self.rootItems];
    
    return;
}

@end
