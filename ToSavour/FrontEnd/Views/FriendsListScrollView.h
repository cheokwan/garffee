//
//  FriendsListScrollView.h
//  ToSavour
//
//  Created by Jason Wan on 6/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvatarView.h"
@class AvatarView;
@class MUserInfo;


@interface FriendsListScrollView : UIScrollView<UIScrollViewDelegate>

- (void)updateView;

@end


@interface FriendsListScrollViewCell : UIView<AvatarViewDelegate>
@property (nonatomic, strong)   AvatarView *avatarView;
@property (nonatomic, strong)   UILabel *nameLabel;

- (id)initWithFrame:(CGRect)frame user:(MUserInfo *)user;

@end
