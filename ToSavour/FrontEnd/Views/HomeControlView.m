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

@implementation HomeControlView

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMMy hh:mm" options:0 locale:[NSLocale currentLocale]];
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
    _lastOrderTimeLabel.text = [[self.class dateFormatter] stringFromDate:[NSDate date]];
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
