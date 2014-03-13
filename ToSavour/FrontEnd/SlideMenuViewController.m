//
//  SlideMenuViewController.m
//  ToSavour
//
//  Created by Jason Wan on 21/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "MUserInfo.h"
#import "MCouponInfo.h"
#import "MProductInfo.h"
#import "MBranch.h"
#import "OngoingOrderTableViewCell.h"
#import "GiftTableViewCell.h"
#import "TSFrontEndIncludes.h"
#import "TSNavigationController.h"
#import "CouponDetailsViewController.h"
#import "OrderDetailsViewController.h"

typedef enum {
    SlideMenuSectionMyOrder = 0,
    SlideMenuSectionGift,
    SlideMenuSectionTotal,
} SlideMenuSection;


@interface SlideMenuViewController ()
@property (nonatomic, strong)   NSFetchedResultsController *ongoingOrderFetchedResultsController;
@property (nonatomic, strong)   NSFetchedResultsController *couponFetchedResultsController;

@property (nonatomic, strong)   OngoingOrderTableViewCell *ongoingOrderPrototypeCell;
@property (nonatomic, strong)   GiftTableViewCell *giftPrototypeCell;
@end

@implementation SlideMenuViewController

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_isFetchNeeded) {
        [[RestManager sharedInstance] fetchAppCouponInfo:self];
        [[RestManager sharedInstance] fetchAppPendingOrderStatus:self];
        self.isFetchNeeded = NO;
    }
    [_tableView reloadData];
}

- (void)initializeView {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.navigationController.navigationBarHidden = YES;
    UIView *statusBarPatch = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    statusBarPatch.backgroundColor = [TSTheming defaultContrastColor];  // for setting the status bar background
    [self.navigationController.view addSubview:statusBarPatch];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - RestManagerResponseHandler

- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(fetchAppCouponInfo:)) {
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:SlideMenuSectionGift] withRowAnimation:UITableViewRowAnimationNone];
    } else if (selector == @selector(fetchAppPendingOrderStatus:)) {
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:SlideMenuSectionMyOrder] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(fetchAppCouponInfo:)) {
        DDLogError(@"error fetching coupon info: %@", error);
    } else if (selector == @selector(fetchAppPendingOrderStatus:)) {
        DDLogError(@"error fetching pending order status: %@", error);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)couponFetchedResultsController {
    if (!_couponFetchedResultsController) {
        NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
        NSFetchRequest *fetchRequest = [MCouponInfo fetchRequest];
        MUserInfo *appUser = [MUserInfo currentAppUserInfoInContext:context];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"receiverUserID = %@ AND (redeemedDate = %@ OR redeemedDate > %@)", appUser.appID, nil, [NSDate date]];
        NSSortDescriptor *sdCreationDate = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
        fetchRequest.sortDescriptors = @[sdCreationDate];
        self.couponFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _couponFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_couponFetchedResultsController performFetch:&error]) {
            DDLogError(@"error fetching coupon list: %@", error);
        }
    }
    return _couponFetchedResultsController;
}

- (NSFetchedResultsController *)ongoingOrderFetchedResultsController {
    if (!_ongoingOrderFetchedResultsController) {
        NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
        NSFetchRequest *fetchRequest = [MOrderInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"status IN[c] %@", @[MOrderInfoStatusPending, MOrderInfoStatusInProgress, MOrderInfoStatusFinished]];
        NSSortDescriptor *sdOrderedDate = [NSSortDescriptor sortDescriptorWithKey:@"orderedDate" ascending:NO];
        fetchRequest.sortDescriptors = @[sdOrderedDate];
        self.ongoingOrderFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _ongoingOrderFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_ongoingOrderFetchedResultsController performFetch:&error]) {
            DDLogError(@"error fetching ongoing orders: %@", error);
        }
    }
    return _ongoingOrderFetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (controller == _ongoingOrderFetchedResultsController) {
        if (indexPath) {
            indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:SlideMenuSectionMyOrder];
        }
        if (newIndexPath) {
            newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:SlideMenuSectionMyOrder];
        }
    } else if (controller == _couponFetchedResultsController) {
        if (indexPath) {
            indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:SlideMenuSectionGift];
        }
        if (newIndexPath) {
            newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:SlideMenuSectionGift];
        }
    }
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[_tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView endUpdates];
}

#pragma mark - UITableView related

- (OngoingOrderTableViewCell *)ongoingOrderPrototypeCell {
    if (!_ongoingOrderPrototypeCell) {
        self.ongoingOrderPrototypeCell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OngoingOrderTableViewCell.class)];
    }
    return _ongoingOrderPrototypeCell;
}

- (GiftTableViewCell *)giftPrototypeCell {
    if (!_giftPrototypeCell) {
        self.giftPrototypeCell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass(GiftTableViewCell.class)];
    }
    return _giftPrototypeCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SlideMenuSectionTotal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SlideMenuSectionMyOrder: {
            return self.ongoingOrderFetchedResultsController.fetchedObjects.count;
        }
            break;
        case SlideMenuSectionGift: {
            return self.couponFetchedResultsController.fetchedObjects.count;
        }
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SlideMenuSectionMyOrder:
            return self.ongoingOrderPrototypeCell.bounds.size.height;
            break;
        case SlideMenuSectionGift:
            return self.giftPrototypeCell.bounds.size.height;
            break;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView viewForHeaderInSection:section].frame.size.height;
}

- (UIView *)sectionHeaderViewWithTitle:(NSString *)title height:(CGFloat)height {
    CGRect headerFrame = CGRectMake(0, 0, self.view.frame.size.width, height);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
    headerView.backgroundColor = [TSTheming defaultContrastColor];
    
    UILabel *headerTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, headerFrame.size.height - 39.0, headerFrame.size.width - 70.0, 34.0)];
    headerTextLabel.textColor = [TSTheming defaultThemeColor];
    headerTextLabel.font = [UIFont systemFontOfSize:17.0];
    headerTextLabel.text = title;
    [headerView addSubview:headerTextLabel];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static UIView *ongoingOrderSectionHeader = nil;
    static UIView *giftSectionHeader = nil;
    
    switch (section) {
        case SlideMenuSectionMyOrder: {
            if (!ongoingOrderSectionHeader) {
                ongoingOrderSectionHeader = [self sectionHeaderViewWithTitle:LS_MY_ORDER height:44.0];
            }
            return ongoingOrderSectionHeader;
        }
            break;
        case SlideMenuSectionGift: {
            if (!giftSectionHeader) {
                giftSectionHeader = [self sectionHeaderViewWithTitle:LS_GIFT height:44.0];
            }
            return giftSectionHeader;
        }
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case SlideMenuSectionMyOrder: {
            cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OngoingOrderTableViewCell.class) forIndexPath:indexPath];
        }
            break;
        case SlideMenuSectionGift: {
            cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass(GiftTableViewCell.class) forIndexPath:indexPath];
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
        case SlideMenuSectionMyOrder: {
            OngoingOrderTableViewCell *orderCell = (OngoingOrderTableViewCell *)cell;
            MOrderInfo *order = self.ongoingOrderFetchedResultsController.fetchedObjects[indexPath.row];
            orderCell.titleLabel.textColor = [TSTheming defaultThemeColor];
            orderCell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", LS_ORDER_NO, order.referenceNumber ? order.referenceNumber : @"None"];
            orderCell.priceLabel.text = [NSString stringWithPrice:[order.price floatValue] showFree:YES];
            orderCell.locationLabel.text = order.storeBranch.name;
            
            __weak OngoingOrderTableViewCell *weakOrderCell = orderCell;
            [orderCell.itemImageView setImageWithURL:[order URLForImageRepresentation] placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (image) {
                    UIImage *resizedImage = [image resizedImageToSize:weakOrderCell.itemImageView.frame.size];
                    weakOrderCell.itemImageView.image = resizedImage;
                } else {
                    DDLogWarn(@"error setting ongoing order image: %@", error);
                }
            }];
            
            [orderCell.orderProgressView updateStatus:order.status];
        }
            break;
        case SlideMenuSectionGift: {
            GiftTableViewCell *giftCell = (GiftTableViewCell *)cell;
            MCouponInfo *coupon  = self.couponFetchedResultsController.fetchedObjects[indexPath.row];
            giftCell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", LS_REF_NO, coupon.referenceCode];
            giftCell.detailLabel.text = [coupon.creationDate defaultStringRepresentation];
            giftCell.giftSenderLabel.text = [NSString stringWithFormat:@"%@ %@", LS_GIFT_FROM, [coupon issuerName]];
            
            __weak GiftTableViewCell *weakGiftCell = giftCell;
            [giftCell.itemImageView setImageWithURL:[coupon URLForImageRepresentation] placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (image) {
                    UIImage *resizedImage = [image resizedImageToSize:weakGiftCell.itemImageView.frame.size];
                    weakGiftCell.itemImageView.image = resizedImage;
                } else {
                    DDLogWarn(@"error setting gift image: %@", error);
                }
            }];
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case SlideMenuSectionMyOrder: {
            OrderDetailsViewController *orderDetailsViewController = (OrderDetailsViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(OrderDetailsViewController.class)];
            orderDetailsViewController.order = self.ongoingOrderFetchedResultsController.fetchedObjects[indexPath.row];
            TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:orderDetailsViewController];
            [self presentViewController:naviController animated:YES completion:nil];
        }
            break;
        case SlideMenuSectionGift: {
            CouponDetailsViewController *couponDetailsViewController = (CouponDetailsViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(CouponDetailsViewController.class)];
            couponDetailsViewController.coupon = self.couponFetchedResultsController.fetchedObjects[indexPath.row];
            TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:couponDetailsViewController];
            [self presentViewController:naviController animated:YES completion:nil];
        }
            break;
    }
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    if (bar == self.navigationController.navigationBar) {
        return UIBarPositionTop;
    }
    return UIBarPositionAny;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
