//
//  SoundwaveRecorder.h
//  ToSavour
//
//  Created by Jason Wan on 21/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
@class SoundwaveRecorder;

static const int kSoundwaveRecorderNumBuffers = 3;

@protocol SoundwaveRecorderDelegate <NSObject>
- (void)soundwaveRecorder:(SoundwaveRecorder *)recorder didReceiveAudioData:(NSData *)audioData;
@end

@interface SoundwaveRecorder : NSObject {
    AudioStreamBasicDescription audioFormat;
    AudioQueueBufferRef recordQueueBuffers[kSoundwaveRecorderNumBuffers];
    AudioQueueRef recordQueue;
    UInt32 bufferByteSize;
    UInt32 bufferNumPackets;
}

@property (nonatomic, assign)   BOOL recording;
@property (nonatomic, weak)     id<SoundwaveRecorderDelegate> delegate;

+ (instancetype)sharedInstance;
- (void)startRecording;
- (void)stopRecording;

@end
