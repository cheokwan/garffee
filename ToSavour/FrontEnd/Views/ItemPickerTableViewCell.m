//
//  ItemPickerTableViewCell.m
//  ToSavour
//
//  Created by Jason Wan on 7/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "ItemPickerTableViewCell.h"

@implementation ItemPickerTableViewCell

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    [self initializeView];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initializeView {
    CGFloat ratio = self.bounds.size.height / 80.0;
    UIImageView *glowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80.0 * ratio, 48.0 * ratio)];
    glowImageView.contentMode = UIViewContentModeScaleAspectFill;
    glowImageView.image = [UIImage imageNamed:@"red"];
    glowImageView.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height - (glowImageView.bounds.size.height / 2.0));
    [self addSubview:glowImageView];
    [self sendSubviewToBack:glowImageView];
    [self bringSubviewToFront:_pickerScrollView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self bringSubviewToFront:_pickerScrollView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
