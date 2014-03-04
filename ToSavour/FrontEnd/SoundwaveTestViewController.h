//
//  SoundwaveTestViewController.h
//  ToSavour
//
//  Created by Jason Wan on 24/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundwaveRecorder.h"
#import "SoundwaveAnalyzer.h"

@interface SoundwaveTestViewController : UIViewController<SoundwaveRecorderDelegate>

@property (nonatomic, strong)   IBOutlet UIButton *recordButton;
@property (nonatomic, strong)   IBOutlet UILabel *displayLabel;
@property (nonatomic, strong)   IBOutlet UISlider *targetFrequencySlider;
@property (nonatomic, strong)   IBOutlet UILabel *targetFrequencyLabel;
@property (nonatomic, strong)   IBOutlet UILabel *displayFrequencyBinLowLabel;
@property (nonatomic, strong)   IBOutlet UILabel *displayFrequencyBinHighLabel;
@property (nonatomic, strong)   IBOutlet UIBarButtonItem *logButton;

// heat map image
@property (nonatomic, strong)   IBOutlet UIImageView *heatMapImage;
@property (nonatomic, assign)   int heatMapRows;
@property (nonatomic, assign)   int heatMapColumns;
@property (nonatomic, assign)   int heatMapCurrentRow;
@property (nonatomic, assign)   int heatMapFrequencyBinLow;
@property (nonatomic, assign)   int heatMapFrequencyBinHigh;

@property (nonatomic, assign)   BOOL isRecording;
@property (nonatomic, strong)   SoundwaveAnalyzer *analyzer;

@end
