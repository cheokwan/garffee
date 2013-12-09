//
//  PhotoHuntViewController.h
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoHuntViewController;
@protocol PhotoHuntViewControllerDelagte <NSObject>
- (void)photoHuntViewControllerDidFinishGame:(PhotoHuntViewController *)controller;
@end

@interface PhotoHuntViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, weak) id<PhotoHuntViewControllerDelagte> delegate;
@property (nonatomic, strong) IBOutlet UISlider *countDownSlider;
@property (nonatomic) float timeLimit;

@end
