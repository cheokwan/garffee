//
//  PhotoHuntViewController.h
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoHuntGridButton.h"
#import "PhotoHuntImageView.h"
#import "PhotoHuntManager.h"
#import "TSGame.h"
#import "RestManager.h"

#define GRID_WIDTH                  10.0f
#define GRID_HEIGHT                 10.0f
#define COUNT_DOWN_UPDATE_INTERVAL  0.1f
#define CHANGE_IMAGE_START_INDEX    1

@class PhotoHuntViewController;
@protocol PhotoHuntViewControllerDelagte <NSObject>
- (void)photoHuntViewControllerDidFinishGame:(PhotoHuntViewController *)controller;
@end

@interface PhotoHuntViewController : UIViewController <UIAlertViewDelegate, PhotoHuntGridButtonDelegate, PhotoHuntManagerDelegate, PhotoHuntImageViewDelegate, RestManagerResponseHandler>

- (id)initWithGameManager:(PhotoHuntManager *)gameManager;

@property (nonatomic, weak) id<PhotoHuntViewControllerDelagte> delegate;
@property (nonatomic, strong) IBOutlet UISlider *countDownSlider;
@property (nonatomic, strong) IBOutlet UIView *sliderContainerView;
@property (nonatomic, strong) IBOutlet PhotoHuntImageView *upperImageView, *lowerImageView;
@property (nonatomic, strong) IBOutlet UILabel *foundChangesLabel;

@end
