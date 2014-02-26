//
//  SoundwaveTestViewController.m
//  ToSavour
//
//  Created by Jason Wan on 24/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "SoundwaveTestViewController.h"
#import "SoundwaveRecorder.h"

@interface SoundwaveTestViewController ()
@property (nonatomic, readonly) NSInteger targetFrequency;
@end

@implementation SoundwaveTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
    self.analyzer = [[SoundwaveAnalyzer alloc] init];
    [_analyzer initializeFFT:[SoundwaveRecorder sharedInstance].bufferNumPackets];
}

- (void)setIsRecording:(BOOL)isRecording {
    _isRecording = isRecording;
    if (!_isRecording) {
        [_recordButton setImage:[UIImage imageNamed:@"PlayIcon"] forState:UIControlStateNormal];
        _displayLabel.text = @"amp";
        _displayFrequencyBinLowLabel.text = @"low";
        _displayFrequencyBinHighLabel.text = @"high";
    } else {
        [_recordButton setImage:[UIImage imageNamed:@"StopIcon"] forState:UIControlStateNormal];
    }
}

- (NSInteger)targetFrequency {
    return _targetFrequencySlider.value;
}

- (void)updateTargetFrequencyLabel {
    _targetFrequencyLabel.text = [NSString stringWithFormat:@"Target Frequency: %@ Hz", [@(self.targetFrequency) stringValue]];
}

- (void)initializeView {
    self.isRecording = NO;
    [_recordButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _displayLabel.font = [UIFont systemFontOfSize:18.0];
    _displayLabel.textAlignment = NSTextAlignmentCenter;
    _displayLabel.textColor = [UIColor darkTextColor];
    
    [_targetFrequencySlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self updateTargetFrequencyLabel];
}

- (void)buttonPressed:(id)sender {
    if (sender == _recordButton) {
        if (!_isRecording) {
            [[SoundwaveRecorder sharedInstance] startRecording];
            [SoundwaveRecorder sharedInstance].delegate = self;
        } else {
            [[SoundwaveRecorder sharedInstance] stopRecording];
            [SoundwaveRecorder sharedInstance].delegate = nil;
        }
        self.isRecording = !_isRecording;
    }
}

- (void)valueChanged:(id)sender {
    if (sender == _targetFrequencySlider) {
        [self updateTargetFrequencyLabel];
    }
}

- (void)stopIfRecording {
    if ([SoundwaveRecorder sharedInstance].isRecording && [SoundwaveRecorder sharedInstance].delegate == self) {
        [[SoundwaveRecorder sharedInstance] stopRecording];
        [SoundwaveRecorder sharedInstance].delegate = nil;
        self.isRecording = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self stopIfRecording];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self stopIfRecording];
}

- (void)soundwaveRecorder:(SoundwaveRecorder *)recorder didReceiveAudioData:(NSData *)audioData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL fftSuccess = [_analyzer computeFFT:audioData];
        FrequencyInfo freqInfo;
        Float32 targetFrequencyLow = [self targetFrequency] - 25.0;
        Float32 targetFrequencyHigh = [self targetFrequency] + 25.0;
        if (fftSuccess) {
            freqInfo = [_analyzer findTargetFrequencyLow:targetFrequencyLow high:targetFrequencyHigh];
        }
        Float32 magnitude = 0.0;
        Float32 freqBinLow = 0.0;
        Float32 freqBinHigh = 0.0;
        if (freqInfo.magnitude > 1e-5) {
            magnitude = freqInfo.magnitude;
            freqBinLow = freqInfo.frequencyBinLow;
            freqBinHigh = freqInfo.frequencyBinHigh;
            DDLogDebug(@"freq bin low: %f, freq bin high: %f, magnitude: %f", freqBinLow, freqBinHigh, magnitude);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _displayLabel.text = [@(magnitude) stringValue];
            _displayFrequencyBinLowLabel.text = [@(freqBinLow) stringValue];
            _displayFrequencyBinHighLabel.text = [@(freqBinHigh) stringValue];
        });
    });
}

@end
