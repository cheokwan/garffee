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

#define ORDER_COMPOSITE_IMAGE_MAX_ITEM  10
static CGRect itemImageRects[ORDER_COMPOSITE_IMAGE_MAX_ITEM];

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
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // XXX-SERVER-BUG: order from history may not have items in them
        //((MItemInfo *)[_order.items anyObject]).product.URLForImageRepresentation;
        // XXXXXX TESTING
//        NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].persistentStoreManagedObjectContext;
        NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
        NSFetchRequest *fetchRequest = [MOrderInfo fetchRequest];
        NSSortDescriptor *sdOrderedDate = [NSSortDescriptor sortDescriptorWithKey:@"orderedDate" ascending:NO];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"status = %@", MOrderInfoStatusInCart];
        fetchRequest.sortDescriptors = @[sdOrderedDate];
        NSError *error = nil;
        NSArray *orders = [context executeFetchRequest:fetchRequest error:&error];
        if (error) {
            DDLogError(@"error fetching products for cached images: %@", error);
        }
        if (orders.count == 0) {
            double delayInSeconds = 5.0;
            DDLogWarn(@"fetched 0 orders, going to retry in %f seconds", delayInSeconds);
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self updateView];
            });
        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *images = [NSMutableArray array];
                MOrderInfo *lastOrder = [orders firstObject];
                for (MItemInfo *item in lastOrder.items) {
                    if (!item.product.localCachedImageURL) {
                        continue;
                    }
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:item.product.localCachedImageURL]];
                    CGRect cropRect = CGRectInset(CGRectMake(0, 0, image.size.width, image.size.height), 15.0, 0.0);
                    
                    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
                    if (croppedImageRef) {
                        UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
                        [images addObject:croppedImage];
                        CGImageRelease(croppedImageRef);
                    } else {
                        [images addObject:image];
                    }
                }
                
                CGRect drawingRect = CGRectInset(self.bounds, 0.0, 0.0);
                [self calculateItemImageRectsBoundTo:drawingRect.size sampleImage:[images firstObject] total:images.count];
                UIGraphicsBeginImageContext(drawingRect.size);
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), drawingRect.origin.x, drawingRect.origin.y);
                NSInteger numImagesToDraw = MIN(images.count, ORDER_COMPOSITE_IMAGE_MAX_ITEM);
                for (NSInteger imageIndex = 0; imageIndex < numImagesToDraw; ++imageIndex) {
                    CGRect imageRect = itemImageRects[imageIndex];
//                    BOOL inFirstRow = (imageRect.origin.y == 0.0);
                    [images[imageIndex] drawInRect:imageRect];
                }
                
                UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                self.contentMode = UIViewContentModeLeft;
                [UIView animateWithDuration:0.3 animations:^{
                    self.alpha = 0.0;
                    self.image = compositeImage;
                    self.alpha = 1.0;
                }];
//            });
        }
//    });
}

- (void)calculateItemImageRectsBoundTo:(CGSize)boundSize sampleImage:(UIImage *)sampleImage total:(NSInteger)total {
    // TODO: make this smarter
    CGFloat sampleHeightWidthRatio = sampleImage.size.height / sampleImage.size.width;
    NSInteger numToDraw = MIN(total, ORDER_COMPOSITE_IMAGE_MAX_ITEM);
    
    // figure out if one row overflows
    CGFloat singleRowItemHeight = 0.8 * boundSize.height;
    CGFloat singleRowItemWidth = singleRowItemHeight / sampleHeightWidthRatio;
    BOOL singleRow = floor(boundSize.width / singleRowItemWidth) >= numToDraw;
    
    // ready to layout the rects
    memset(itemImageRects, 0, sizeof(CGRect) & ORDER_COMPOSITE_IMAGE_MAX_ITEM);
    if (singleRow) {
        CGFloat leftMargin = (boundSize.width - (singleRowItemWidth * numToDraw)) / 2.0;
        CGFloat topMargin = (boundSize.height - singleRowItemHeight) / 2.0;
        CGRect sampleRect = CGRectMake(leftMargin, topMargin, singleRowItemWidth, singleRowItemHeight);
        for (NSInteger i = 0; i < numToDraw; ++i) {
            CGRect itemRect = CGRectOffset(sampleRect, i * singleRowItemWidth, 0.0);
            itemImageRects[i] = itemRect;
        }
    } else {
        // just do maximum two rows for now... TODO...
        NSInteger numInFirstRow = ceil(numToDraw / 2.0);
        NSInteger numInSecondRow = numToDraw - numInFirstRow;
        
        // if we have too much items, then we are fucked... choose the MAX wisely TODO...
        CGFloat firstRowItemHeight = 0.7 * boundSize.height;
        CGFloat secondRowItemHeight = 0.8 * boundSize.height;
        
        CGFloat firstRowItemWidth = firstRowItemHeight / sampleHeightWidthRatio;
        CGFloat secondRowItemWidth = secondRowItemHeight / sampleHeightWidthRatio;
        
        CGFloat firstRowLeftMargin = (boundSize.width - (firstRowItemWidth * numInFirstRow)) / 2.0;
        CGRect firstRowSampleRect = CGRectMake(firstRowLeftMargin, 0.0, firstRowItemWidth, firstRowItemHeight);
        for (NSInteger i = 0; i < numInFirstRow; ++i) {
            CGRect itemRect = CGRectOffset(firstRowSampleRect, i * firstRowItemWidth, 0.0);
            itemImageRects[i] = itemRect;
        }
        
        CGFloat secondRowLeftMargin = (boundSize.width - (secondRowItemWidth * numInSecondRow)) / 2.0;
        if (numInFirstRow == numInSecondRow && numToDraw != ORDER_COMPOSITE_IMAGE_MAX_ITEM) {
//            secondRowLeftMargin += (firstRowItemWidth / 2.0);
        }
        CGRect secondRowSampleRect = CGRectMake(secondRowLeftMargin, boundSize.height - secondRowItemHeight, secondRowItemWidth, secondRowItemHeight);
        for (NSInteger i = 0; i < numInSecondRow; ++i) {
            CGRect itemRect = CGRectOffset(secondRowSampleRect, i * secondRowItemWidth, 0.0);
            itemImageRects[numInFirstRow + i] = itemRect;
        }
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
