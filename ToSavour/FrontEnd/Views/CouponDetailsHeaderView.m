//
//  CouponDetailsHeaderView.m
//  ToSavour
//
//  Created by Jason Wan on 10/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "CouponDetailsHeaderView.h"
#import "TSFrontEndIncludes.h"
#import "CartHeaderView.h"


// TODO: refactor cart header view to be more generic so we
// don't need to hack it

@implementation CouponDetailsHeaderView

- (void)initializeView {
    self.refTitleLabel.text = LS_REF_NO;
    self.fromLabel.text = LS_GIFT_FROM;
    [self updateSender:nil];
    [self updateReferenceNumber:nil];
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

- (void)updateSender:(MUserInfo *)newSender {
    NSString *nameToShow = nil;
    if ([newSender.firstName trimmedWhiteSpaces].length > 0) {
        nameToShow = newSender.firstName;
    } else if ([newSender.name trimmedWhiteSpaces].length > 0) {
        nameToShow = newSender.name;
    } else {
        nameToShow = @"";
    }
    self.nameLabel.text = nameToShow;
    
    AvatarView *newAvatarView = [[AvatarView alloc] initWithFrame:self.senderAvatarView.frame user:newSender showAccessoryImage:NO interactable:NO];
    [_senderAvatarView removeFromSuperview];
    self.senderAvatarView = newAvatarView;
    [self.bottomBar addSubview:_senderAvatarView];
}

- (void)updateReferenceNumber:(NSString *)referenceNumber {
    self.refNumLabel.text = referenceNumber;
}

- (BOOL)hasSender {
    return [self.nameLabel.text trimmedWhiteSpaces].length != 0;
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
