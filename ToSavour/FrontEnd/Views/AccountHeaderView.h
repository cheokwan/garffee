//
//  AccountHeaderView.h
//  ToSavour
//
//  Created by Jason Wan on 14/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvatarView.h"
@class AccountHeaderView;

@protocol AccountHeaderViewDelegate <NSObject>
- (void)accountHeaderView:(AccountHeaderView *)accountHeaderView didSwitchToTableSegment:(NSInteger)segmentIndex;
@end

@interface AccountHeaderView : UIView

@property (nonatomic, strong)   IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong)   IBOutlet AvatarView *avatarView;
@property (nonatomic, strong)   IBOutlet UILabel *nameLabel;
@property (nonatomic, strong)   IBOutlet UISegmentedControl *tableSwitcher;
@property (nonatomic, weak)     id<AccountHeaderViewDelegate> delegate;

@end
