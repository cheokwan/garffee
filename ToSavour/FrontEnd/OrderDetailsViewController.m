//
//  OrderDetailsViewController.m
//  ToSavour
//
//  Created by Jason Wan on 14/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "OrderDetailsViewController.h"
#import "TSTheming.h"
#import "OrderItemTableViewCell.h"
#import "MOrderInfo.h"

typedef enum {
    OrderDetailsSectionPickupLocation = 0,
    OrderDetailsSectionItems,
    OrderDetailsSectionTotal,
} OrderDetailsSection;

@interface OrderDetailsViewController ()
@property (nonatomic, strong)   OrderItemTableViewCell *orderItemPrototypeCell;
@property (nonatomic, readonly) NSArray *orderItems;
@end

@implementation OrderDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)initializeView {
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_ORDER_DETAILS];
    self.navigationItem.rightBarButtonItem = self.dismissButton;
    
    OrderDetailsHeaderView *orderDetailsHeader = (OrderDetailsHeaderView *)[TSTheming viewWithNibName:NSStringFromClass(OrderDetailsHeaderView.class)];
    orderDetailsHeader.frame = self.headerView.frame;
    self.headerView = orderDetailsHeader;
    [_headerView updateOrderNumber:_order.referenceNumber];
    [_headerView updatePrice:[_order.price floatValue]];
    [_headerView.orderProgressView updateStatus:_order.status];
    [self.view addSubview:_headerView];
    
    _orderDetailsList.dataSource = self;
    _orderDetailsList.delegate = self;
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(OrderItemTableViewCell.class) bundle:[NSBundle mainBundle]];
    [_orderDetailsList registerNib:nib forCellReuseIdentifier:NSStringFromClass(OrderItemTableViewCell.class)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (UIBarButtonItem *)dismissButton {
    if (!_dismissButton) {
        self.dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ico_close"] style:UIBarButtonItemStylePlain target:self action:@selector(buttonPressed:)];
        _dismissButton.tintColor = [TSTheming defaultAccentColor];
    }
    return _dismissButton;
}

- (void)buttonPressed:(id)sender {
    if (sender == _dismissButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSArray *)orderItems {
    return [[self.order.items allObjects] sortedArrayUsingSelector:@selector(creationDate)];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (OrderItemTableViewCell *)orderItemPrototypeCell {
    if (!_orderItemPrototypeCell) {
        self.orderItemPrototypeCell = [_orderDetailsList dequeueReusableCellWithIdentifier:NSStringFromClass(OrderItemTableViewCell.class)];
    }
    return _orderItemPrototypeCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return OrderDetailsSectionTotal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case OrderDetailsSectionPickupLocation: {
            return 0;
        }
            break;
        case OrderDetailsSectionItems: {
            return self.orderItems.count;
        }
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case OrderDetailsSectionPickupLocation: {
            return 0.0;
        }
            break;
        case OrderDetailsSectionItems: {
            return self.orderItemPrototypeCell.frame.size.height;
        }
            break;
    }
    return 0.0;
}

- (UIView *)sectionHeaderViewWithTitle:(NSString *)title height:(CGFloat)height {
    CGRect headerFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, height);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
    
    UILabel *headerTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.5, headerFrame.size.width - 10.0, height - 1.0)];
    headerTextLabel.font = [UIFont systemFontOfSize:12.0];
    headerTextLabel.text = title;
    [headerView addSubview:headerTextLabel];
    headerView.backgroundColor = _orderDetailsList.backgroundColor;
    headerTextLabel.backgroundColor = _orderDetailsList.backgroundColor;
    
    // XXX-FIX: top and bottom line glitch
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, headerFrame.size.width, 0.5)];
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, headerFrame.size.height - 0.5, headerFrame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor lightGrayColor];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:topLine];
    [headerView addSubview:bottomLine];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static UIView *pickupLocationSectionHeader = nil;
    static UIView *orderItemsSectionHeader = nil;
    
    switch (section) {
        case OrderDetailsSectionPickupLocation: {
            if (!pickupLocationSectionHeader) {
                pickupLocationSectionHeader = [self sectionHeaderViewWithTitle:LS_PICK_UP_LOCATION height:25.0];
            }
            return pickupLocationSectionHeader;
        }
            break;
        case OrderDetailsSectionItems: {
            if (!orderItemsSectionHeader) {
                orderItemsSectionHeader = [self sectionHeaderViewWithTitle:LS_ORDER_ITEMS height:25.0];
            }
            return orderItemsSectionHeader;
        }
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case OrderDetailsSectionPickupLocation: {
            cell = nil;
        }
            break;
        case OrderDetailsSectionItems: {
            cell = [_orderDetailsList dequeueReusableCellWithIdentifier:NSStringFromClass(OrderItemTableViewCell.class) forIndexPath:indexPath];
        }
            break;
    }
    if (cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case OrderDetailsSectionPickupLocation: {
        }
            break;
        case OrderDetailsSectionItems: {
            OrderItemTableViewCell *orderItemCell = (OrderItemTableViewCell *)cell;
            MItemInfo *itemInfo = self.orderItems[indexPath.row];
            [orderItemCell configureWithItem:itemInfo];
        }
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end