//
//  SoundwaveRecorder.m
//  ToSavour
//
//  Created by Jason Wan on 21/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "SoundwaveRecorder.h"

@implementation SoundwaveRecorder

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _recording = NO;
        [self setUpAudioFormat];
        [self setUpRecordQueue];
        [self setUpRecordQueueBuffers];
    }
    return self;
}

static void recordCallBack(
    void *inUserData,
    AudioQueueRef inAudioQueue,
    AudioQueueBufferRef inBuffer,
    const AudioTimeStamp *inStartTime,
    UInt32 inNumPackets,
    const AudioStreamPacketDescription *inPacketDesc) {
    
    SoundwaveRecorder *recorder = (__bridge SoundwaveRecorder *)inUserData;
    if (!recorder.recording) {
        return;
    }
    
    if (inNumPackets > 0) {
        NSData *audioData = [NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        if ([recorder.delegate respondsToSelector:@selector(soundwaveRecorder:didReceiveAudioData:)]) {
            [recorder.delegate soundwaveRecorder:recorder didReceiveAudioData:audioData];
        }
    }
    AudioQueueEnqueueBuffer(
                            inAudioQueue,   // AudioQueueRef
                            inBuffer,       // AudioQueueBufferRef
                            0,              // inNumPacketDescs
                            NULL            // AudioStreamPacketDescription
                            );
}

- (void)setUpAudioFormat {
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mSampleRate = 44100.0;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mBytesPerFrame = audioFormat.mChannelsPerFrame * sizeof(SInt16);
    audioFormat.mBytesPerPacket = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame;
    audioFormat.mFormatFlags = kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    
    bufferNumPackets = 2048;    // FFT requires num packets to be power of 2
    bufferByteSize = bufferNumPackets * audioFormat.mBytesPerPacket;
}

- (void)setUpRecordQueue {
    AudioQueueNewInput(
                       &audioFormat,            // AudioStreamBasicDescription
                       recordCallBack,          // AudioQueueInputCallback
                       (__bridge void *)self,   // inUserData
                       CFRunLoopGetMain(),      // inCallbackRunLoop
                       NULL,                    // inCallbackRunLoopMode
                       0,                       // inFlags
                       &recordQueue             // outAQ
                       );
}

- (void)setUpRecordQueueBuffers {
    for (int i = 0; i < kSoundwaveRecorderNumBuffers; ++i) {
        AudioQueueAllocateBuffer(
                                 recordQueue,           // AudioQueueRef
                                 bufferByteSize,        // inBufferByteSize
                                 &recordQueueBuffers[i] // AudioQueueBufferRef
                                 );
    }
}

- (void)primeRecordQueueBuffers {
    for (int i = 0; i < kSoundwaveRecorderNumBuffers; ++i) {
        AudioQueueEnqueueBuffer(
                                recordQueue,            // AudioQueueRef
                                recordQueueBuffers[i],  // AudioQueueBufferRef
                                0,                      // inNumPacketDescs
                                NULL                    // AudioStreamPacketDescription
                                );
    }
}

- (void)startRecording {
    _recording = YES;
    [self primeRecordQueueBuffers];
    AudioQueueStart(
                    recordQueue,    // AudioQueueRef
                    NULL            // AudioTimeStamp
                    );
}

- (void)stopRecording {
    _recording = NO;
    AudioQueueStop(
                   recordQueue,     // AudioQueueRef
                   true             // inImmediate
                   );
}

- (void)dealloc {
    AudioQueueDispose(
                      recordQueue,  // AudioQueueRef
                      true          // inImmediate
                      );
}

@end
