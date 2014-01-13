//
//  CouponDetailsHeaderView.h
//  ToSavour
//
//  Created by Jason Wan on 10/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "CartHeaderView.h"

@interface CouponDetailsHeaderView : UIView

@property (nonatomic, strong)   IBOutlet UIView *topBar;
@property (nonatomic, strong)   IBOutlet UILabel *refTitleLabel;
@property (nonatomic, strong)   IBOutlet UILabel *refNumLabel;

@property (nonatomic, strong)   IBOutlet UIView *bottomBar;
@property (nonatomic, strong)   IBOutlet UILabel *fromLabel;
@property (nonatomic, strong)   IBOutlet AvatarView *senderAvatarView;
@property (nonatomic, strong)   IBOutlet UILabel *nameLabel;

- (void)updateSender:(MUserInfo *)newSender;
- (void)updateReferenceNumber:(NSString *)referenceNumber;
- (BOOL)hasSender;

@end
