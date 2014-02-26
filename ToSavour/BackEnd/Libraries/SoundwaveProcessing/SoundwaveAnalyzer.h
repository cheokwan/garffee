//
//  SoundwaveAnalyzer.h
//  ToSavour
//
//  Created by Jason Wan on 25/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

typedef struct {
    Float32 frequencyBinLow;
    Float32 frequencyBinHigh;
    Float32 magnitude;
} FrequencyInfo;

@interface SoundwaveAnalyzer : NSObject {
    UInt32          fftLength;
    UInt32          log2N;
    FFTSetup        spectrumAnalysis;
    DSPSplitComplex dspSplitComplex;
    Float32         *windowFunction;
    Float32         *workingSamples;
    Float32         *outputData;
    Float32         sampleRate;
}

- (void)initializeFFT:(UInt32)numOfFrames;
- (BOOL)computeFFT:(NSData *)inSamples;
- (FrequencyInfo)findTargetFrequencyLow:(Float32)freqLow high:(Float32)freqHigh;
- (FrequencyInfo)findDominantFrequency;

@end
