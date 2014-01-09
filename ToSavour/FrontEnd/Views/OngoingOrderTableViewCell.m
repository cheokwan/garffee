//
//  OngoingOrderTableViewCell.m
//  ToSavour
//
//  Created by Jason Wan on 8/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "OngoingOrderTableViewCell.h"

@implementation OngoingOrderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initializeView {
    self.itemImageView.layer.cornerRadius = 2.0;
}

- (void)awakeFromNib {
    [self initializeView];
}

@end
