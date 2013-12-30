//
//  AccountHeaderView.m
//  ToSavour
//
//  Created by Jason Wan on 14/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "AccountHeaderView.h"
#import "TSFrontEndIncludes.h"
#import "AppDelegate.h"
#import "MUserInfo.h"

@implementation AccountHeaderView

- (void)initialize {
    self.clipsToBounds = NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)init {
    self = [self init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initializeView {
    MUserInfo *user = [MUserInfo currentUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    
    NSURL *profilePicURL = [NSURL URLWithString:user.fbProfilePicURL];
    [_avatarView removeFromSuperview];
    self.avatarView = [[AvatarView alloc] initWithFrame:self.avatarView.frame avatarImageURL:profilePicURL accessoryImageURL:[NSURL URLWithString:@"http://files.softicons.com/download/social-media-icons/simple-icons-by-dan-leech/png/128x128/facebook.png"] interactable:YES];  // XXX-TEST
    _avatarView.avatarButton.imageView.layer.borderColor = [UIColor whiteColor].CGColor;  // XXX-TEST
    _avatarView.avatarButton.imageView.layer.borderWidth = 2.0;  // XXX-TEST
    
    UIImage *testImage = [UIImage imageNamed:@"AvatarBackground"];
    testImage = [testImage resizedImageToSize:self.backgroundImageView.frame.size];
    _backgroundImageView.image = testImage;
    
    _nameLabel.textColor = [TSTheming defaultAccentColor];  // TODO: dynamically change based on background
    _nameLabel.text = user.fbName;
    
    _tableSwitcher.selectedSegmentIndex = 0;
    [_tableSwitcher setTintColor:[TSTheming defaultThemeColor]];
    [_tableSwitcher addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:self.avatarView];
}

- (void)awakeFromNib {
    [self initializeView];
}

- (void)valueChanged:(id)sender {
    if (sender == _tableSwitcher) {
        if ([_delegate respondsToSelector:@selector(accountHeaderView:didSwitchToTableSegment:)]) {
            [_delegate accountHeaderView:self didSwitchToTableSegment:_tableSwitcher.selectedSegmentIndex];
        }
    }
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
