//
//  HomeControlView.m
//  ToSavour
//
//  Created by Jason Wan on 6/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "HomeControlView.h"
#import "TSFrontEndIncludes.h"
#import "MUserInfo.h"
#import "MOrderInfo.h"
#import "MItemInfo.h"
#import "MProductInfo.h"
#import "OrderCompositeImageView.h"

@implementation HomeControlView

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMMy hh:mm" options:0 locale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];  // XXX TODO: change to current locale after localizing the whole app
        [dateFormatter setDateFormat:formatString];
    });
    return dateFormatter;
}

- (void)initializeView {
    _lastOrderLabel.text = LS_LAST_ORDER;
    _orderNowButton.titleLabel.numberOfLines = 2;
    _orderNowButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _orderNowButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_orderNowButton setTitle:LS_ORDER_NOW forState:UIControlStateNormal];
    [_orderNowButton setTintColor:[TSTheming defaultThemeColor]];
    _friendsLabel.text = LS_FRIENDS;
    _lastOrderTimeLabel.textColor = [TSTheming defaultThemeColor];
}

- (void)updateView {
    CGFloat balance = [((MUserInfo *)[MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext]).creditBalance floatValue];
    _balanceLabel.text = [NSString stringWithFormat:@"%@: %@", LS_BALANCE, [NSString stringWithPrice:balance]];
    
    [self updateLastOrder];
}

- (void)updateLastOrder {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].persistentStoreManagedObjectContext;
        NSFetchRequest *fetchRequest = [MOrderInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"status =[c] %@", MOrderInfoStatusPickedUp];
        NSSortDescriptor *sdOrderedDate = [[NSSortDescriptor alloc] initWithKey:@"orderedDate" ascending:NO];
        fetchRequest.sortDescriptors = @[sdOrderedDate];
        NSError *error = nil;
        NSArray *lastOrders = [context executeFetchRequest:fetchRequest error:&error];
        if (error) {
            DDLogError(@"error fetching last orders: %@", error);
        }
        
        // filter out the last order from virtual type such as recharge
        MOrderInfo *lastOrder = nil;
        // XXX-SERVER-BUG: order history returns no items
        lastOrder = [lastOrders firstObject];
//        for (MOrderInfo *order in lastOrders) {
//            MItemInfo *item = [order.items anyObject];
//            if ([item.product.type isCaseInsensitiveEqual:MProductInfoTypeReal]) {
//                lastOrder = order;
//                break;
//            }
//        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (lastOrder) {
                NSManagedObjectContext *mainContext = [AppDelegate sharedAppDelegate].managedObjectContext;
                MOrderInfo *mainLastOrder = (MOrderInfo *)[mainContext objectWithID:lastOrder.objectID];
                _lastOrderTimeLabel.text = [[self.class dateFormatter] stringFromDate:mainLastOrder.orderedDate];
                
                UIImageView *lastOrderImage = [[OrderCompositeImageView alloc] initWithFrame:_lastOrderImage.frame order:mainLastOrder];
                [_lastOrderImage removeFromSuperview];
                self.lastOrderImage = lastOrderImage;
                [self addSubview:_lastOrderImage];
            } else {
                _lastOrderTimeLabel.text = LS_NEVER;
            }
        });
    });
}

- (void)awakeFromNib {
    [self initializeView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
