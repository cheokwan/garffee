//
//  SoundwaveAnalyzer.h
//  ToSavour
//
//  Created by Jason Wan on 25/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface SoundwaveAnalyzer : NSObject {
    UInt32          fftLength;
    UInt32          log2N;
    FFTSetup        fftSetup;
    DSPSplitComplex splitComplex;
}

@end
