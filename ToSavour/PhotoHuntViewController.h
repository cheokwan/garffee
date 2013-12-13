//
//  PhotoHuntViewController.h
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoHuntGridButton.h"

#define CHANGE_GROUP_NONE           -1

@class PhotoHuntViewController;
@protocol PhotoHuntViewControllerDelagte <NSObject>
- (void)photoHuntViewControllerDidFinishGame:(PhotoHuntViewController *)controller;
@end

@interface PhotoHuntViewController : UIViewController <UIAlertViewDelegate, PhotoHuntGridButtonDelegate>

@property (nonatomic, weak) id<PhotoHuntViewControllerDelagte> delegate;
@property (nonatomic, strong) IBOutlet UISlider *countDownSlider;
@property (nonatomic, strong) IBOutlet UIView *sliderContainerView;
@property (nonatomic, strong) IBOutlet UIImageView *upperImageView, *lowerImageView;
@property (nonatomic) float timeLimit;
@property (nonatomic, strong) NSString *filePackageName;

@end
