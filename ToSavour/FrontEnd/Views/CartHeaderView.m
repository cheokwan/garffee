//
//  CartHeaderView.m
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "CartHeaderView.h"
#import "AppDelegate.h"
#import "TSFrontEndIncludes.h"
#import <QuartzCore/QuartzCore.h>

@implementation CartHeaderView

- (void)initializeView {
    _totalLabel.text = LS_TOTAL;
    _totalLabel.textColor = [TSTheming defaultThemeColor];
    _priceLabel.textColor = [TSTheming defaultThemeColor];
    [_checkoutButton setTitle:LS_CHECK_OUT forState:UIControlStateNormal];
    _checkoutButton.backgroundColor = [TSTheming defaultThemeColor];
    _checkoutButton.tintColor = [TSTheming defaultAccentColor];
    _checkoutButton.layer.cornerRadius = 5.0;
    _toLabel.text = LS_TO;
    [self updateRecipient:nil];
    [self updateTotalPrice:0.0];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)updateTotalPrice:(CGFloat)price {
    static NSString *priceFormatString = @"HK: $%.1f";
    _priceLabel.text = [NSString stringWithFormat:priceFormatString, price];
}

- (void)updateRecipient:(MUserInfo *)newRecipient {
    MUserInfo *appUser = [MUserInfo currentUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    NSString *nameToShow = nil;
    if ([newRecipient isEqual:appUser]) {
        nameToShow = LS_ME;
    } else if ([newRecipient.fbFirstName trimmedWhiteSpaces].length > 0) {
        nameToShow = newRecipient.fbFirstName;
    } else if ([newRecipient.fbName trimmedWhiteSpaces].length > 0) {
        nameToShow = newRecipient.fbName;
    } else {
        nameToShow = @"";
    }
    self.nameLabel.text = nameToShow;
    
    AvatarView *newAvatarView = [[AvatarView alloc] initWithFrame:self.recipientAvatarView.frame avatarImageURL:[NSURL URLWithString:newRecipient.fbProfilePicURL] accessoryImageURL:nil interactable:NO];
    [_recipientAvatarView removeFromSuperview];
    self.recipientAvatarView = newAvatarView;
    [self.recipientBar addSubview:_recipientAvatarView];
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
