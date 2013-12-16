//
//  CartViewController.m
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "CartViewController.h"
#import "TSFrontEndIncludes.h"
#import "CartItemTableViewCell.h"
#import "AppDelegate.h"
#import "TSNavigationController.h"
#import "ItemPickerViewController.h"

typedef enum {
    CartSectionItems,
    CartSectionPromotion,
} CartSection;

@interface CartViewController ()
@property (nonatomic, strong)   CartItemTableViewCell *cartItemPrototypeCell;

@end

@implementation CartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
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

- (void)initializeView {
    _itemList.delegate = self;
    _itemList.dataSource = self;
    CartHeaderView *cartHeader = (CartHeaderView *)[TSTheming viewWithNibName:NSStringFromClass(CartHeaderView.class) owner:self];
    cartHeader.frame = self.cartHeaderView.frame;
    self.cartHeaderView = cartHeader;
    [self.view addSubview:_cartHeaderView];
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_CART];
    self.navigationItem.leftBarButtonItem = self.addOrderButton;
}

- (UIBarButtonItem *)addOrderButton {
    if (!_addOrderButton) {
        self.addOrderButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonPressed:)];
        _addOrderButton.tintColor = [TSTheming defaultAccentColor];
    }
    return _addOrderButton;
}

- (void)buttonPressed:(id)sender {
    if (sender == _addOrderButton) {
        ItemPickerViewController *itemPicker = (ItemPickerViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(ItemPickerViewController.class)];
        TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:itemPicker];
        [self presentViewController:naviController animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;  // XXX-TEST
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;  // XXX-TEST
}

- (CartItemTableViewCell *)cartItemPrototypeCell {
    if (!_cartItemPrototypeCell) {
        self.cartItemPrototypeCell = [_itemList dequeueReusableCellWithIdentifier:NSStringFromClass(CartItemTableViewCell.class)];
    }
    return _cartItemPrototypeCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cartItemPrototypeCell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [_itemList dequeueReusableCellWithIdentifier:NSStringFromClass(CartItemTableViewCell.class) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

@end
