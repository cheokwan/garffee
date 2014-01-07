//
//  FriendsListScrollView.m
//  ToSavour
//
//  Created by Jason Wan on 6/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "FriendsListScrollView.h"
#import "AvatarView.h"
#import "MUserInfo.h"

@implementation FriendsListScrollView

- (void)initialize {
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.clipsToBounds = YES;
//    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
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

- (void)awakeFromNib {
    NSFetchRequest *fetchRequest = [MUserInfo fetchRequestInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isAppUser = %@", @NO];
    NSSortDescriptor *sdUserType = [[NSSortDescriptor alloc] initWithKey:@"userType" ascending:YES];
    NSSortDescriptor *sdName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
//    fetchRequest.fetchLimit = 50;
    fetchRequest.sortDescriptors = @[sdUserType, sdName];
    NSError *error = nil;
    NSArray *friends = [[AppDelegate sharedAppDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DDLogError(@"error fetching friends in home screen: %@", error);
    }
    
    CGFloat frameWidth = self.frame.size.height * 2.5 / 3.0;
    CGFloat offsetX = 0.0;
    for (MUserInfo *friend in friends) {
        CGRect cellFrame = CGRectMake(offsetX, 0, frameWidth, self.frame.size.height);
        FriendsListScrollViewCell *cell = [[FriendsListScrollViewCell alloc] initWithFrame:cellFrame user:friend];
        [self addSubview:cell];
        offsetX += frameWidth;
    }
    self.contentSize = CGSizeMake(offsetX, self.frame.size.height);
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


@implementation FriendsListScrollViewCell

- (id)initWithFrame:(CGRect)frame user:(MUserInfo *)user {
    if (frame.size.width > frame.size.height) {
        frame.size.width = frame.size.height;  // make the frame at least a square
    }
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat avatarViewHeight = frame.size.height - 35.0;
        CGRect avatarViewFrame = CGRectMake((frame.size.width - avatarViewHeight) / 2.0, 10.0, avatarViewHeight, avatarViewHeight);
        self.avatarView = [[AvatarView alloc] initWithFrame:avatarViewFrame user:user showAccessoryImage:YES interactable:YES];
        
        CGRect nameLabelFrame = CGRectMake(5.0, avatarViewHeight + 15.0, frame.size.width - 10.0, 15.0);
        self.nameLabel = [[UILabel alloc] initWithFrame:nameLabelFrame];
        _nameLabel.font = [UIFont systemFontOfSize:10.0];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.text = user.name;
        
        [self addSubview:_avatarView];
        [self addSubview:_nameLabel];
    }
    return self;
}

@end
