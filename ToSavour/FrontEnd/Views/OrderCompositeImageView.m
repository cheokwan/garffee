//
//  OrderCompositeImageView.m
//  ToSavour
//
//  Created by Jason Wan on 28/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "OrderCompositeImageView.h"
#import "MItemInfo.h"
#import "MProductInfo.h"

@implementation OrderCompositeImageView

- (void)initialize {
    self.layer.cornerRadius = 3.5;
    self.layer.masksToBounds = YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame order:(MOrderInfo *)order {
    self = [self initWithFrame:frame];
    if (self) {
        self.order = order;
        [self updateView];
    }
    return self;
}

- (void)updateView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // XXX-SERVER-BUG: order from history may not have items in them
        //((MItemInfo *)[_order.items anyObject]).product.URLForImageRepresentation;
        NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].persistentStoreManagedObjectContext;
        NSFetchRequest *fetchRequest = [MProductInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localCachedImageURL != %@ AND name IN[c] %@", nil, @[/*@"Cappuccino",*/ @"Coffee"/*, @"Latte"*/]];
        NSError *error = nil;
        NSArray *products = [context executeFetchRequest:fetchRequest error:&error];
        if (error) {
            DDLogError(@"error fetching products for cached images: %@", error);
        }
        if (products.count == 0) {
            double delayInSeconds = 3.0;
            DDLogWarn(@"fetched 0 products, going to retry in %f seconds", delayInSeconds);
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self updateView];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *images = [NSMutableArray array];
                for (MProductInfo *product in products) {
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:product.localCachedImageURL]];
                    [images addObject:image];
                }
                
                CGFloat imageMargin = 10.0;  // XXXXXX
                UIImage *sampleImage = [images lastObject];
                CGFloat sampleImageProportionWidth = (sampleImage.size.width * self.bounds.size.height / sampleImage.size.height) - (imageMargin * 2.0);
                CGSize itemImageSize = CGSizeMake(sampleImageProportionWidth, self.bounds.size.height);
                CGFloat x = 0.0;
                CGFloat dx = 0.0;
                if (self.bounds.size.width > images.count * itemImageSize.width) {
                    // the imageview can fit all the item images
                    dx = itemImageSize.width;
                } else {
                    // item images will need to be overlapped
                    // last item remains on top of all others
                    dx = (self.bounds.size.width - itemImageSize.width) / (CGFloat)(images.count - 1);
                }
                
                UIGraphicsBeginImageContext(self.bounds.size);
//                CGContextRef c = UIGraphicsGetCurrentContext();  XXXXXX
                
                for (UIImage *image in images) {
                    CGFloat imageProportionalWidth = (image.size.width * itemImageSize.height / image.size.height);
                    CGRect imageRect = CGRectMake(x - imageMargin, 0, imageProportionalWidth, itemImageSize.height);
                    
//                    CGContextSaveGState(c); {
//                        CGContextSetFillColorWithColor(c, [UIColor whiteColor].CGColor);
//                        CGContextSetShadow(c, CGSizeMake(-7.0, 0.0), 3.0);
//                        CGRect shadowRect = CGRectMake(imageRect.origin.x + imageRect.size.width / 4.0, imageRect.origin.y + imageRect.size.height / 4.0, imageRect.size.width / 2.0, imageRect.size.height / 2.0);
//                        //CGContextFillRect(c, shadowRect);
//                        CGContextFillEllipseInRect(c, shadowRect);
//                    } CGContextRestoreGState(c);
                    
                    [image drawInRect:imageRect];
                    x += dx;
                }
                UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                self.contentMode = UIViewContentModeLeft;
                self.image = compositeImage;
            });
        }
    });
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
