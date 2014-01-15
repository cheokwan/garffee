//
//  PickUpLocationTableViewCell.m
//  ToSavour
//
//  Created by LAU Leung Yan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "PickUpLocationTableViewCell.h"
#import "TSFrontEndIncludes.h"
#import <QuartzCore/QuartzCore.h>

@implementation PickUpLocationTableViewCell

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm" options:0 locale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:formatString];
    });
    return dateFormatter;
}

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

- (void)configureWithBranch:(MBranch *)branch {
    self.branch = branch;
    
    //thumbnail
    _thumbnailImageView.backgroundColor = [UIColor clearColor];
    _thumbnailImageView.layer.masksToBounds = YES;
    _thumbnailImageView.layer.cornerRadius = 5.0;
    
    __weak UIImageView *weakThumbnailImageVew = _thumbnailImageView;
    __weak MBranch *weakBranch = _branch;
    [_thumbnailImageView setImageWithURL:[_branch URLForThumbnailImage] placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            UIImage *resizedImage = [image resizedImageToFitInSize:weakThumbnailImageVew.frame.size scaleIfSmaller:YES];
            weakThumbnailImageVew.image = resizedImage;
        } else {
            DDLogError(@"error setting branch thumbnail images %@: %@", [weakBranch URLForThumbnailImage], error);
        }
    }];
    
    //others
    _branchNameLabel.text = _branch.name;
    _openingHourLabel.text = [self openingHourString];
    _telephoneNumberLabel.text = _branch.phoneNumber;
    _openingHourImageView.contentMode = UIViewContentModeScaleAspectFit;
    _openingHourImageView.image = [UIImage imageNamed:@"ico_time"];
    _telephoneNumberImageView.contentMode = UIViewContentModeScaleAspectFit;
    _telephoneNumberImageView.image = [UIImage imageNamed:@"ico_phone"];
}

- (NSString *)openingHourString {
    NSString *openTimeStr = [self.class.dateFormatter stringFromDate:_branch.openTime];
    NSString *closeTimeStr = [self.class.dateFormatter stringFromDate:_branch.closeTime];
    return [NSString stringWithFormat:@"%@ - %@", openTimeStr, closeTimeStr];
}

@end
