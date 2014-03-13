//
//  PromotionScrollView.m
//  ToSavour
//
//  Created by Jason Wan on 7/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "PromotionScrollView.h"
#import "TSFrontEndIncludes.h"

@implementation PromotionScrollView

- (void)initialize {
}

- (void)initializeView {
    // XXX-STUB: stub for promotional images, TODO: replace with real service call
    NSArray *promotionImageURLs = @[[TSTheming URLWithImageAssetNamed:@"promo_1"],
                                    [TSTheming URLWithImageAssetNamed:@"promo_2"],
                                    [TSTheming URLWithImageAssetNamed:@"promo_3"]];
    
    self.promotionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _promotionScrollView.showsHorizontalScrollIndicator = NO;
    _promotionScrollView.showsVerticalScrollIndicator = NO;
    _promotionScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _promotionScrollView.pagingEnabled = YES;
    _promotionScrollView.delegate = self;
    
    CGFloat offsetX = 0.0;
    CGSize frameSize = CGSizeMake(_promotionScrollView.bounds.size.width, _promotionScrollView.bounds.size.height);
    for (NSURL *imageURL in promotionImageURLs) {
        CGRect imageFrame = CGRectMake(offsetX, 0, frameSize.width, frameSize.height);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = imageFrame;
        button.imageView.frame = imageFrame;
        button.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        button.imageView.layer.cornerRadius = 5.0;
        
        __weak UIButton *weakButton = button;
        __weak NSURL *weakImageURL = imageURL;
        [button.imageView setImageWithURL:imageURL placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                UIImage *resizedImage = [image resizedImageToSize:frameSize];
                [weakButton setImage:resizedImage forState:UIControlStateNormal];
            } else {
                DDLogWarn(@"error setting promotion image %@: %@", weakImageURL, error);
            }
        }];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_promotionScrollView addSubview:button];
        offsetX += frameSize.width;
    }
    _promotionScrollView.contentSize = CGSizeMake(offsetX, frameSize.height);
    
    self.promotionPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frameSize.height - 25.0, frameSize.width, 15.0)];
    _promotionPageControl.numberOfPages = promotionImageURLs.count;
    _promotionPageControl.pageIndicatorTintColor = [[TSTheming defaultThemeColor] colorWithAlphaComponent:0.5];
    _promotionPageControl.currentPageIndicatorTintColor = [TSTheming defaultThemeColor];
    
    [self addSubview:_promotionScrollView];
    [self addSubview:_promotionPageControl];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializeView];
}

- (NSInteger)getCurrentPageIndex {
    CGFloat pageIndex = _promotionScrollView.contentOffset.x / _promotionScrollView.bounds.size.width;
    return lround(pageIndex);
}

- (void)buttonPressed:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        if ([_delegate respondsToSelector:@selector(promotionScrollView:didSelectPromotionAtIndex:)]) {
            [_delegate promotionScrollView:self didSelectPromotionAtIndex:[self getCurrentPageIndex]];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _promotionScrollView) {
        _promotionPageControl.currentPage = [self getCurrentPageIndex];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
