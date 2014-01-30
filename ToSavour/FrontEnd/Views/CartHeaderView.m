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
    [_removeRecipientButton setImage:[UIImage imageNamed:@"ico_remove"] forState:UIControlStateNormal];
    [_removeRecipientButton setImage:nil forState:UIControlStateDisabled];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, self.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    self.backgroundColor = [TSTheming defaultBackgroundTransparentColor];
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
    _priceLabel.text = [NSString stringWithPrice:price];
}

- (void)updateRecipient:(MUserInfo *)newRecipient {
    if (newRecipient.appID.length == 0) {
        newRecipient = nil;
    }
    MUserInfo *appUser = [MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    NSString *nameToShow = nil;
    if ([newRecipient isEqual:appUser]) {
        nameToShow = LS_ME;
    } else if ([newRecipient.firstName trimmedWhiteSpaces].length > 0) {
        nameToShow = newRecipient.firstName;
    } else if ([newRecipient.name trimmedWhiteSpaces].length > 0) {
        nameToShow = newRecipient.name;
    } else {
        nameToShow = @"";
    }
    self.nameLabel.text = nameToShow;
    
    AvatarView *newAvatarView = [[AvatarView alloc] initWithFrame:self.recipientAvatarView.frame user:newRecipient showAccessoryImage:NO interactable:NO];
    [_recipientAvatarView removeFromSuperview];
    self.recipientAvatarView = newAvatarView;
    [self.recipientBar addSubview:_recipientAvatarView];
    
    _removeRecipientButton.enabled = newRecipient != nil && ![newRecipient isEqual:appUser];
    _removeRecipientButton.hidden = !_removeRecipientButton.enabled;
}

- (BOOL)hasRecipient {
    return [self.nameLabel.text trimmedWhiteSpaces].length != 0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
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
