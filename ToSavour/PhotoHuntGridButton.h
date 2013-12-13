//
//  PhotoHuntGridButton.h
//  ToSavour
//
//  Created by LAU Leung Yan on 13/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoHuntGridButton;
@protocol PhotoHuntGridButtonDelegate <NSObject>
- (void)photoHuntGridButton:(PhotoHuntGridButton *)button didPressedWithChangeGroup:(NSString *)changeGroup;
@end

@interface PhotoHuntGridButton : UIButton

@property (nonatomic, assign) int buttonIndex;
@property (nonatomic, strong) NSString *changeGroup;
@property (nonatomic, assign) BOOL isFound;
@property (nonatomic, assign) id<PhotoHuntGridButtonDelegate> delegate;

@end
