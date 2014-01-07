//
//  PickUpLocationTableViewCell.m
//  ToSavour
//
//  Created by LAU Leung Yan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "PickUpLocationTableViewCell.h"

#import <UIImage-Resize/UIImage+Resize.h>

@implementation PickUpLocationTableViewCell

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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_branch.thumbnailURL]];
    __weak UIImageView *imageView = _thumbnailImageView;
    [_thumbnailImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
        imageView.image = [image resizedImageToSize:imageView.frame.size];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        DDLogCDebug(@"download thumbnail failed: %@", error);
    }];
    
    //others
    _branchNameLabel.text = _branch.name;
    _openingHourLabel.text = [self openingHourString];
    _telephoneNumberLabel.text = _branch.phoneNumber;
}

- (NSString *)openingHourString {
    NSString *openTimeStr = [_dateFormatter stringFromDate:_branch.openTime];
    NSString *closeTimeStr = [_dateFormatter stringFromDate:_branch.closeTime];
    return [NSString stringWithFormat:@"%@ - %@", openTimeStr, closeTimeStr];
}

@end
