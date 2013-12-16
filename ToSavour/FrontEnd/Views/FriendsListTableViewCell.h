//
//  FriendsListTableViewCell.h
//  ToSavour
//
//  Created by Jason Wan on 12/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvatarView.h"

@interface FriendsListTableViewCell : UITableViewCell

@property (nonatomic, strong)   IBOutlet AvatarView *avatarView;
@property (nonatomic, strong)   IBOutlet UILabel *title;
@property (nonatomic, strong)   IBOutlet UILabel *subtitle;

@end
