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
}

- (void)setIsRecording:(BOOL)isRecording {
    _isRecording = isRecording;
    if (!_isRecording) {
        [_recordButton setImage:[UIImage imageNamed:@"PlayIcon"] forState:UIControlStateNormal];
    } else {
        [_recordButton setImage:[UIImage imageNamed:@"StopIcon"] forState:UIControlStateNormal];
    }
}

- (void)initializeView {
    self.isRecording = NO;
    [_recordButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _displayLabel.font = [UIFont systemFontOfSize:18.0];
    _displayLabel.textAlignment = NSTextAlignmentCenter;
    _displayLabel.textColor = [UIColor darkTextColor];
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

- (void)stopIfRecording {
    if ([SoundwaveRecorder sharedInstance].recording && [SoundwaveRecorder sharedInstance].delegate == self) {
        [[SoundwaveRecorder sharedInstance] stopRecording];
        [SoundwaveRecorder sharedInstance].delegate = nil;
        self.isRecording = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopIfRecording];
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
        UInt8 *pPacket = (UInt8 *)audioData.bytes;
        UInt8 *pEnd = ((UInt8 *)audioData.bytes) + audioData.length;
        SInt16 sample = 0;
        float runningAverage = 0;
        int count = 0;
        while (pPacket < pEnd) {
            ++count;
            sample = ntohs(*(SInt16 *)(pPacket));
            runningAverage = (runningAverage + sample) / (float)count;
            pPacket += sizeof(SInt16);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _displayLabel.text = [@(runningAverage) stringValue];
        });
    });
}

@end
