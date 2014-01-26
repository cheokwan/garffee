//
//  AccountInfoTableViewCell.m
//  ToSavour
//
//  Created by Jason Wan on 14/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "AccountInfoTableViewCell.h"

@implementation AccountInfoTableViewCell

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

- (void)setCustomView:(UIView *)customView {
    _customView = customView;
    [self addSubview:_customView];
}

@end
