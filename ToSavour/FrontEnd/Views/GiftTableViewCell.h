//
//  GiftTableViewCell.h
//  ToSavour
//
//  Created by Jason Wan on 8/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftTableViewCell : UITableViewCell

@property (nonatomic, strong)   IBOutlet UIImageView *itemImageView;
@property (nonatomic, strong)   IBOutlet UILabel *titleLabel;
@property (nonatomic, strong)   IBOutlet UILabel *detailLabel;
@property (nonatomic, strong)   IBOutlet UILabel *giftSenderLabel;

@end
