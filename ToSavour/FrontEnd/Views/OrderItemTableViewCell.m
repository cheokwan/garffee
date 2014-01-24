//
//  OrderItemTableViewCell.m
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "OrderItemTableViewCell.h"
#import "TSFrontEndIncludes.h"
#import "MProductInfo.h"

@interface OrderItemTableViewCell()
@property (nonatomic, assign)   UITableViewCellStateMask previousState;
@end

@implementation OrderItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithItem:(MItemInfo *)item {
    __weak OrderItemTableViewCell *weakSelf = self;
    [self.itemImageView setImageWithURL:[NSURL URLWithString:item.product.resolvedImageURL] placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            weakSelf.itemImageView.image = [image resizedImageToSize:weakSelf.itemImageView.frame.size];
        } else {
            DDLogWarn(@"cannot set image for item: %@ - error %@", weakSelf.itemNameLabel.text, error);
        }
    }];
    
    self.itemNameLabel.text = item.product.name;
    self.itemDetailsLabel.text = item.description;  // TODO: fill in this detail
    self.priceLabel.text = [NSString stringWithPrice:[item.price floatValue]];
    self.quantityLabel.text = [NSString stringWithFormat:@"%@: %d", LS_QUANTITY, 1];  // TODO: handle quantity
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    if (self.previousState & UITableViewCellStateShowingEditControlMask) {
//        [UIView animateWithDuration:0.2 animations:^{
//            _priceLabel.alpha = 0.0;
//        }];
//        if (self.showingDeleteConfirmation) {
//            // hide addtional suckers
//        }
//    } else {
//        [UIView animateWithDuration:0.2 animations:^{
//            _priceLabel.alpha = 1.0;
//        }];
//    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    self.previousState = state;
}

@end
