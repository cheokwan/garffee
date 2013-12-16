//
//  CartHeaderView.h
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvatarView.h"
#import "MUserInfo.h"

@interface CartHeaderView : UIView

@property (nonatomic, strong)   IBOutlet UIView *priceBar;
@property (nonatomic, strong)   IBOutlet UILabel *totalLabel;
@property (nonatomic, strong)   IBOutlet UILabel *priceLabel;
@property (nonatomic, strong)   IBOutlet UIButton *checkoutButton;

@property (nonatomic, strong)   IBOutlet UIView *recipientBar;
@property (nonatomic, strong)   IBOutlet UILabel *toLabel;
@property (nonatomic, strong)   IBOutlet AvatarView *recipientAvatarView;
@property (nonatomic, strong)   IBOutlet UILabel *nameLabel;

- (void)updateRecipient:(MUserInfo *)newRecipient;

@end
