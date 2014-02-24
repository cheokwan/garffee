//
//  SoundwaveTestViewController.h
//  ToSavour
//
//  Created by Jason Wan on 24/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundwaveRecorder.h"

@interface SoundwaveTestViewController : UIViewController<SoundwaveRecorderDelegate>

@property (nonatomic, strong)   IBOutlet UIButton *recordButton;
@property (nonatomic, strong)   IBOutlet UILabel *displayLabel;
@property (nonatomic, assign)   BOOL isRecording;

@end
