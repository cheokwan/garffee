//
//  SoundwaveAnalyzer.m
//  ToSavour
//
//  Created by Jason Wan on 25/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "SoundwaveAnalyzer.h"

@implementation SoundwaveAnalyzer
@synthesize fftLength = fftLength;
@synthesize outputData = outputData;
@synthesize sampleRate = sampleRate;

- (id)init {
    self = [super init];
    if (self) {
        fftLength = 0;
        log2N = 0;
        spectrumAnalysis = NULL;
        dspSplitComplex.realp = NULL;
        dspSplitComplex.imagp = NULL;
        windowFunction = NULL;
        workingSamples = NULL;
        outputData = NULL;
        sampleRate = 44100.0;
    }
    return self;
}

- (void)initializeFFT:(UInt32)numOfFrames {
    fftLength = numOfFrames;
    log2N = ceilf(log2f(numOfFrames));
    dspSplitComplex.realp = (Float32 *)malloc(fftLength * sizeof(Float32));
    dspSplitComplex.imagp = (Float32 *)malloc(fftLength * sizeof(Float32));
    spectrumAnalysis = vDSP_create_fftsetup(log2N, kFFTRadix2);
    windowFunction = [self makeHanningWindow];
    workingSamples = (Float32 *)malloc(fftLength * sizeof(Float32));
    outputData = (Float32 *)malloc(fftLength * sizeof(Float32));
}

- (Float32 *)makeHanningWindow {
    Float32 *window = (Float32 *)malloc(fftLength * sizeof(Float32));
    memset(window, 0, fftLength * sizeof(Float32));
//    for (int i = 0; i < fftLength; ++i) {
//        window[i] = 0.5 * (1.0 - cosf((2.0 * M_PI * i) / (fftLength - 1.0)));
//    }
    vDSP_hann_window(window, fftLength, 0);
    return window;
}

- (BOOL)computeFFT:(NSData *)inSamples {
    SInt32 numSamples = (SInt32)(inSamples.length / sizeof(Float32));
    if (fftLength == 0 || numSamples != fftLength) {
        return NO;
    }
    memset(workingSamples, 0, fftLength * sizeof(Float32));
    memset(dspSplitComplex.realp, 0, fftLength * sizeof(Float32));
    memset(dspSplitComplex.imagp, 0, fftLength * sizeof(Float32));
    memset(outputData, 0, fftLength * sizeof(Float32));
    
    vDSP_vmul(inSamples.bytes, 1, windowFunction, 1, workingSamples, 1, fftLength);  // apply window to the input samples
    
    vDSP_ctoz((DSPComplex *)workingSamples, 2, &dspSplitComplex, 1, fftLength / 2);  // generate split complext vector
    
    vDSP_fft_zrip(spectrumAnalysis, &dspSplitComplex, 1, log2N, kFFTDirection_Forward);  // perform FFT
    
//    Float32 normalizedFactor = 1.0 / (2.0 * fftLength);
//    vDSP_vsmul(dspSplitComplex.realp, 1, &normalizedFactor, dspSplitComplex.realp, 1, fftLength);
//    vDSP_vsmul(dspSplitComplex.imagp, 1, &normalizedFactor, dspSplitComplex.imagp, 1, fftLength);
    
    // some crazy nyquist shit
    dspSplitComplex.realp[fftLength / 2] = dspSplitComplex.imagp[0];
    dspSplitComplex.imagp[fftLength / 2] = 0.0;
    dspSplitComplex.imagp[0] = 0.0;
    
    vDSP_zvmags(&dspSplitComplex, 1, outputData, 1, fftLength);  // calculate magnitude square
    
    // convert to db
//    Float32 adjust0DB = 1.5849e-13;
//    Float32 one = 1.0;
//    vDSP_vsadd(outputData, 1, &adjust0DB, outputData, 1, fftLength);
//    vDSP_vdbcon(outputData, 1, &one, outputData, 1, fftLength, 0);
    
    return YES;
}

- (FrequencyInfo)findTargetFrequencyLow:(Float32)freqLow high:(Float32)freqHigh {
    UInt32 binLow = MIN(floorf(freqLow * fftLength / sampleRate), fftLength);  // 44.1 kHz sample rate
    UInt32 binHigh = MIN(ceilf(freqHigh * fftLength / sampleRate), fftLength);
    
    Float32 magnitudeMax = -FLT_MAX;
    UInt32 binMax = 0;
    for (UInt32 bin = binLow; bin < binHigh; ++bin) {
        if (outputData[bin] > magnitudeMax) {
            magnitudeMax = outputData[bin];
            binMax = bin;
        }
    }
    
    FrequencyInfo freqInfo;
    freqInfo.frequencyBinLow = binMax * sampleRate / fftLength;
    freqInfo.frequencyBinHigh = (binMax + 1) * sampleRate / fftLength;
    freqInfo.magnitude = magnitudeMax;
    return freqInfo;
}

- (FrequencyInfo)findDominantFrequency {
    return [self findTargetFrequencyLow:0.0 high:sampleRate];
}

- (void)dealloc {
    if (spectrumAnalysis) {
        vDSP_destroy_fftsetup(spectrumAnalysis);
    }
    if (dspSplitComplex.realp) {
        free(dspSplitComplex.realp);
    }
    if (dspSplitComplex.imagp) {
        free(dspSplitComplex.imagp);
    }
    if (windowFunction) {
        free(windowFunction);
    }
    if (workingSamples) {
        free(workingSamples);
    }
    if (outputData) {
        free(outputData);
    }
}

@end
