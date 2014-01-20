//
//  BranchDetailsImageCell.m
//  ToSavour
//
//  Created by LAU Leung Yan on 16/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "BranchDetailsImageCell.h"

#import <UIImageView+WebCache.h>
#import "TSFrontEndIncludes.h"

@implementation BranchDetailsImageCell

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

- (void)awakeFromNib {
    [super awakeFromNib];
    _branchImageView.layer.cornerRadius = 5.0f;
    _branchImageView.layer.masksToBounds = YES;
}

- (void)setBranchImageURL:(NSURL *)branchImageURL {
    _branchImageURL = branchImageURL;
    __weak UIImageView *weakImageView = _branchImageView;
    [_branchImageView setImageWithURL:_branchImageURL placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            // assume the image dimension is correct
            // set the image to be larger so it is still clear when it is scaled up
            CGSize scaleUpSize = CGSizeMake(weakImageView.frame.size.width * 1.5, weakImageView.frame.size.height * 1.5);
            weakImageView.image = [image resizedImageToSize:scaleUpSize];
        }
    }];
}

@end
