//
//  HomeControlView.h
//  ToSavour
//
//  Created by Jason Wan on 6/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOrderInfo.h"
@class FriendsListScrollView;

@interface HomeControlView : UIView

@property (nonatomic, strong)   IBOutlet UILabel *lastOrderLabel;
@property (nonatomic, strong)   IBOutlet UILabel *lastOrderTimeLabel;
@property (nonatomic, strong)   IBOutlet UILabel *balanceLabel;
@property (nonatomic, strong)   IBOutlet UILabel *friendsLabel;
@property (nonatomic, strong)   IBOutlet UIButton *orderNowButton;
@property (nonatomic, strong)   IBOutlet UIImageView *lastOrderImage;
@property (nonatomic, strong)   IBOutlet FriendsListScrollView *friendsScrollView;

@property (nonatomic, strong)   MOrderInfo *cachedLastOrder;

- (void)updateView;

@end
