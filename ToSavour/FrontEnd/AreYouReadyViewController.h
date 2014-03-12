//
//  AreYouReadyViewController.h
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountDownButton.h"

@class AreYouReadyViewController;
@protocol AreYouReadyViewControllerDelegate <NSObject>
- (void)areYouReadyViewControllerDidFinishCountDown:(AreYouReadyViewController *)controller;
@end

@interface AreYouReadyViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *areYouReadyStrLabel;
@property (nonatomic, strong) IBOutlet CountDownButton *num3Button, *num2Button, *num1Button;
@property (nonatomic, weak) id<AreYouReadyViewControllerDelegate> delegate;

@end
