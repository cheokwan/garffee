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
#import "TSFrontEndIncludes.h"
#import "CartViewController.h"

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
    [super awakeFromNib];
    [self updateView];
}

- (void)updateView {
    // fetch friends in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].persistentStoreManagedObjectContext;
        NSFetchRequest *fetchRequest = [MUserInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isAppUser = %@ AND userType = %@", @NO, @(MUserInfoUserTypeAppNativeUser)];
        NSSortDescriptor *sdUserType = [[NSSortDescriptor alloc] initWithKey:@"userType" ascending:YES];
        NSSortDescriptor *sdName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        fetchRequest.sortDescriptors = @[sdUserType, sdName];
        //fetchRequest.includesPropertyValues = NO;
        NSError *error = nil;
        NSArray *friends = [context executeFetchRequest:fetchRequest error:&error];
        if (error) {
            DDLogError(@"error fetching friends in scroll view: %@", error);
        }
        if (friends.count == 0) {
            // TODO: better handle this
            double delayInSeconds = 3.0;
            DDLogWarn(@"fetched 0 friends, going to retry in %f seconds", delayInSeconds);
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self updateView];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeAllSubviews];
                self.alpha = 0.0;
                CGFloat frameWidth = self.frame.size.height * 2.5 / 3.0;
                CGFloat offsetX = 0.0;
                NSManagedObjectContext *mainContext = [AppDelegate sharedAppDelegate].managedObjectContext;
                for (MUserInfo *friendWithID in friends) {
                    MUserInfo *friend = (MUserInfo *)[mainContext objectWithID:friendWithID.objectID];
                    CGRect cellFrame = CGRectMake(offsetX, 0, frameWidth, self.frame.size.height);
                    FriendsListScrollViewCell *cell = [[FriendsListScrollViewCell alloc] initWithFrame:cellFrame user:friend];
                    [self addSubview:cell];
                    offsetX += frameWidth;
                }
                self.contentSize = CGSizeMake(offsetX, self.frame.size.height);
                [UIView animateWithDuration:0.3 animations:^{
                    self.alpha = 1.0;
                }];
            });
        }
    });
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
        _avatarView.delegate = self;
        
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

#pragma mark - AvatarViewDelegate

- (void)avatarButtonPressedInAvatarView:(AvatarView *)avatarView {
    MainTabBarController *tabBarController = [AppDelegate sharedAppDelegate].mainTabBarController;
    CartViewController *cart = (CartViewController *)[tabBarController viewControllerAtTab:MainTabBarControllerTabCart];
    if ([cart isKindOfClass:CartViewController.class]) {
        [cart updateRecipient:avatarView.user];
    }
    [tabBarController switchToTab:MainTabBarControllerTabCart animated:YES];
}

- (void)accessoryButtonPressedInAvatarView:(AvatarView *)avatarView {
    // ignore
}

@end
