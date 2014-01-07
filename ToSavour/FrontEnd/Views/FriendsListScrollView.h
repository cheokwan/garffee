//
//  FriendsListScrollView.h
//  ToSavour
//
//  Created by Jason Wan on 6/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AvatarView;
@class MUserInfo;


@interface FriendsListScrollView : UIScrollView<UIScrollViewDelegate>

- (void)updateView;

@end


@interface FriendsListScrollViewCell : UIView
@property (nonatomic, strong)   AvatarView *avatarView;
@property (nonatomic, strong)   UILabel *nameLabel;

- (id)initWithFrame:(CGRect)frame user:(MUserInfo *)user;

@end
