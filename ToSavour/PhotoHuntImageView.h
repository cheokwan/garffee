//
//  PhotoHuntImageView.h
//  ToSavour
//
//  Created by LAU Leung Yan on 14/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PRESS_WRONG_RED_FLASH_DURATION  0.5f

@class PhotoHuntImageView;
@protocol PhotoHuntImageViewDelegate <NSObject>
- (void)photoHuntImageViewDidPress:(PhotoHuntImageView *)imageView;
@end

@interface PhotoHuntImageView : UIImageView

@property (nonatomic, assign) id<PhotoHuntImageViewDelegate> delegate;

@end
