//
//  SoundwaveAnalyzer.m
//  ToSavour
//
//  Created by Jason Wan on 25/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "SoundwaveAnalyzer.h"

@implementation SoundwaveAnalyzer

- (void)initializeFFT:(int)numOfFrames {
    fftLength = numOfFrames;
    log2N = ceilf(log2f(numOfFrames));
    splitComplex.realp = (Float32 *)malloc(fftLength * sizeof(Float32));
    splitComplex.imagp = (Float32 *)malloc(fftLength * sizeof(Float32));
    fftSetup = vDSP_create_fftsetup(log2N, kFFTRadix2);
}

- (BOOL)computeFFT:(NSData *)fftData {
    return NO;
}

- (void)dealloc {
    vDSP_destroy_fftsetup(fftSetup);
    free(splitComplex.realp);
    free(splitComplex.imagp);
}

@end
