//
//  SoundwaveTestViewController.m
//  ToSavour
//
//  Created by Jason Wan on 24/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "SoundwaveTestViewController.h"
#import "SoundwaveRecorder.h"
#import "SoundwaveLogViewController.h"
#import "TSFrontEndIncludes.h"
#import "TSNavigationController.h"
#import "MFrequencyInfo.h"

@interface SoundwaveTestViewController ()
@property (nonatomic, readonly) NSInteger targetFrequency;
@property (nonatomic, assign)   Float32 *heatMapCircularFrameBuffer;
@property (nonatomic, assign)   UInt16 *heatMapWindowCounts;
@property (nonatomic, assign)   CGColorSpaceRef heatMapColorSpace;
@property (nonatomic, assign)   CGDataProviderRef heatMapDataProvider;
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
    
    _heatMapCurrentRow = 0;
    _heatMapRows = _heatMapImage.frame.size.height;
    _heatMapColumns = _heatMapImage.frame.size.width;
    _heatMapFrequencyBinLow = MIN(floorf(15160.0 * _analyzer.fftLength / _analyzer.sampleRate), _analyzer.fftLength);
    _heatMapFrequencyBinHigh = MIN(ceilf(22050.0 * _analyzer.fftLength / _analyzer.sampleRate), _analyzer.fftLength);
    _heatMapCircularFrameBuffer = malloc(sizeof(Float32) * _heatMapRows * _heatMapColumns);
    memset(_heatMapCircularFrameBuffer, 0x00, sizeof(Float32) * _heatMapRows * _heatMapColumns);
    _heatMapWindowCounts = malloc(sizeof(UInt16) * _heatMapColumns);
    memset(_heatMapWindowCounts, 0, sizeof(UInt16) * _heatMapColumns);
    
    _heatMapColorSpace = CGColorSpaceCreateDeviceRGB();
    _heatMapDataProvider = CGDataProviderCreateDirect(_heatMapCircularFrameBuffer,                        // info
                                                      _heatMapRows * _heatMapColumns * sizeof(Float32),   // size
                                                      &providerCallbacks         // CGDataProviderDirectCallbacks
                                                      );
}

- (void)setIsRecording:(BOOL)isRecording {
    _isRecording = isRecording;
    if (!_isRecording) {
        [_recordButton setImage:[UIImage imageNamed:@"PlayIcon"] forState:UIControlStateNormal];
        _displayLabel.text = @"mag";
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
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:@"Soundwave"];
    [_recordButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _displayLabel.font = [UIFont systemFontOfSize:18.0];
    _displayLabel.textAlignment = NSTextAlignmentCenter;
    _displayLabel.textColor = [UIColor darkTextColor];
    
    [_targetFrequencySlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self updateTargetFrequencyLabel];
    
    [_logButton setTarget:self];
    [_logButton setAction:@selector(buttonPressed:)];
}

- (void)buttonPressed:(id)sender {
    if (sender == _recordButton) {
        if (!_isRecording) {
            memset(_heatMapWindowCounts, 0, sizeof(UInt16) * _heatMapColumns);
            [[SoundwaveRecorder sharedInstance] startRecording];
            [SoundwaveRecorder sharedInstance].delegate = self;
        } else {
            [[SoundwaveRecorder sharedInstance] stopRecording];
            [SoundwaveRecorder sharedInstance].delegate = nil;
        }
        self.isRecording = !_isRecording;
    } else if (sender == _logButton) {
        SoundwaveLogViewController *logViewController = (SoundwaveLogViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(SoundwaveLogViewController.class)];
        TSNavigationController *naviController = [[TSNavigationController alloc] initWithRootViewController:logViewController];
        [self presentViewController:naviController animated:YES completion:nil];
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
    free(_heatMapCircularFrameBuffer);
    free(_heatMapWindowCounts);
    CGColorSpaceRelease(_heatMapColorSpace);
    CGDataProviderRelease(_heatMapDataProvider);
}

#pragma mark - heat map related

const void* GetBytePointer(void* info)
{
    // this is currently only called once
    return info; // info is a pointer to the buffer
}

void ReleaseBytePointer(void*info, const void* pointer)
{
    // don't care, just using the one static buffer at the moment
}

size_t GetBytesAtPosition(void* info, void* buffer, off_t position, size_t count)
{
    // I don't think this ever gets called
    memcpy(buffer, ((char*)info) + position, count);
    return count;
}

CGDataProviderDirectCallbacks providerCallbacks =
{ 0, GetBytePointer, ReleaseBytePointer, GetBytesAtPosition, 0 };

- (void)colorForValue:(double)value red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha
{
    // This number should be between 0 and 1
    static const CGFloat kSBAlphaPivotX = 0.333;
    // This number should be between 0 and MAX_ALPHA
    static const CGFloat kSBAlphaPivotY = 0.5;
    // This number should be between 0 and 1
    static const CGFloat kSBMaxAlpha = 0.85;
    
    if (value > 1) value = 1;
    value = sqrt(value);
    
    if (value < kSBAlphaPivotY) {
        *alpha = value * kSBAlphaPivotY / kSBAlphaPivotX;
    } else {
        *alpha = kSBAlphaPivotY + ((kSBMaxAlpha - kSBAlphaPivotY) / (1 - kSBAlphaPivotX)) * (value - kSBAlphaPivotX);
    }
    
    //formula converts a number from 0 to 1.0 to an rgb color.
    //uses MATLAB/Octave colorbar code
    if(value <= 0) {
        *red = *green = *blue = *alpha = 0;
    } else if(value < 0.125) {
        *red = *green = 0;
        *blue = 4 * (value + 0.125);
    } else if(value < 0.375) {
        *red = 0;
        *green = 4 * (value - 0.125);
        *blue = 1;
    } else if(value < 0.625) {
        *red = 4 * (value - 0.375);
        *green = 1;
        *blue = 1 - 4 * (value - 0.375);
    } else if(value < 0.875) {
        *red = 1;
        *green = 1 - 4 * (value - 0.625);
        *blue = 0;
    } else {
        *red = MAX(1 - 4 * (value - 0.875), 0.5);
        *green = *blue = 0;
    }
}

#pragma mark - SoundwaveRecorderDelegate

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
        Float32 normalMax = 1000.0;
        Float32 noiseThreshold = 1.0 / normalMax;
        if (freqInfo.magnitude > noiseThreshold) {
            magnitude = freqInfo.magnitude;
            freqBinLow = freqInfo.frequencyBinLow;
            freqBinHigh = freqInfo.frequencyBinHigh;
            DDLogDebug(@"freq bin low: %f, freq bin high: %f, magnitude: %f", freqBinLow, freqBinHigh, magnitude);
        }
        
        int averageWindow = (_heatMapFrequencyBinHigh - _heatMapFrequencyBinLow) / _heatMapColumns;  // TODO: assuming bin range > heatMapColumns
        for (int i = 0, j = _heatMapFrequencyBinLow; i < _heatMapColumns; ++i, j += averageWindow) {
            Float32 averageSum = 0.0;
            for (int k = j; k < j + averageWindow; ++k) {
                averageSum += fabs(_analyzer.outputData[k]);
            }
            Float32 normalizedMagnitude = MIN(MAX((averageSum / averageWindow) / normalMax, noiseThreshold), 1.0);
            
            Float32 normalizedCountThreshold = 0.01;
            if (normalizedMagnitude > normalizedCountThreshold) {
                ++_heatMapWindowCounts[i];
            } else {
                // basically AIMD
                _heatMapWindowCounts[i] /= 2;
            }
            if (_heatMapWindowCounts[i] == 50) {
                MFrequencyInfo *freqInfo = [MFrequencyInfo newObjectInContext:[AppDelegate sharedAppDelegate].persistentStoreManagedObjectContext];
                freqInfo.timestamp = [NSDate date];
                freqInfo.frequencyBinLow = @(j * _analyzer.sampleRate / _analyzer.fftLength);
                freqInfo.frequencyBinHigh = @((j + averageWindow) * _analyzer.sampleRate / _analyzer.fftLength);
                freqInfo.normalizedMagnitude = @(normalizedMagnitude);
                [[AppDelegate sharedAppDelegate].persistentStoreManagedObjectContext save];
            }
            
            CGFloat red, green, blue, alpha;
            [self colorForValue:normalizedMagnitude red:&red green:&green blue:&blue alpha:&alpha];
            
            int offsetI = i + _heatMapCurrentRow * _heatMapColumns;
            int nextLineOffsetI = (offsetI + _heatMapColumns) % (_heatMapRows * _heatMapColumns);
            _heatMapCircularFrameBuffer[offsetI] = ((UInt32)(red * 255) << 16) + ((UInt32)(green * 255) << 8) + ((UInt32)(blue * 255));
            _heatMapCircularFrameBuffer[nextLineOffsetI] = (255 << 8) + 255;  // draw a yellow scan line
        }
        _heatMapCurrentRow = (_heatMapCurrentRow + 1) % _heatMapRows;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _displayLabel.text = [@(magnitude) stringValue];
            _displayFrequencyBinLowLabel.text = [@(freqBinLow) stringValue];
            _displayFrequencyBinHighLabel.text = [@(freqBinHigh) stringValue];
            
            CGImageRef cgImage = CGImageCreate(_heatMapColumns,        // width
                                               _heatMapRows,           // height
                                               8,                      // bitsPerComponent
                                               32,                     // bitsPerPixel
                                               _heatMapColumns * 4,    // bytesPerRow
                                               _heatMapColorSpace,     // CGColorSpaceRef
                                               kCGImageAlphaNone | kCGBitmapByteOrder32Host,  // CGBitmapInfo
                                               _heatMapDataProvider,   // CGDataProviderRef
                                               0,                      // decode
                                               false,                  // shouldInterpolate
                                               kCGRenderingIntentDefault   // CGColorRenderingIntent
                                               );
            _heatMapImage.layer.contents = (__bridge id)cgImage;
            CGImageRelease(cgImage);
        });
    });
}

@end
