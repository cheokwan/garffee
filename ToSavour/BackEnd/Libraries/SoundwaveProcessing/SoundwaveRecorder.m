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
    
    if (inNumPackets > 0) {
        NSData *audioData = [NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        if ([recorder.delegate respondsToSelector:@selector(soundwaveRecorder:didReceiveAudioData:)]) {
            [recorder.delegate soundwaveRecorder:recorder didReceiveAudioData:audioData];
        }
        fprintf(stderr, "recorder callback fired: %f", [[NSDate date] timeIntervalSinceReferenceDate]);  //JJJ
    }
    OSStatus status = AudioQueueEnqueueBuffer(
                                              inAudioQueue,   // AudioQueueRef
                                              inBuffer,       // AudioQueueBufferRef
                                              0,              // inNumPacketDescs
                                              NULL            // AudioStreamPacketDescription
                                              );
    if (status != noErr) {
        fprintf(stderr, "error in enqueuing buffer during audio queue callback, error status: %d", (int)status);
    }
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
    OSStatus status = AudioQueueNewInput(
                                         &audioFormat,            // AudioStreamBasicDescription
                                         recordCallBack,          // AudioQueueInputCallback
                                         (__bridge void *)self,   // inUserData
                                         CFRunLoopGetMain(),      // inCallbackRunLoop
                                         NULL,                    // inCallbackRunLoopMode
                                         0,                       // inFlags
                                         &recordQueue             // outAQ
                                         );
    if (status != noErr) {
        DDLogError(@"error in setting up audio queue, error status: %d", (int)status);
    }
}

- (void)setUpRecordQueueBuffers {
    for (int i = 0; i < kSoundwaveRecorderNumBuffers; ++i) {
        OSStatus status = AudioQueueAllocateBuffer(
                                                   recordQueue,           // AudioQueueRef
                                                   bufferByteSize,        // inBufferByteSize
                                                   &recordQueueBuffers[i] // AudioQueueBufferRef
                                                   );
        if (status != noErr) {
            DDLogError(@"error in allocating buffer for audio queue, error status: %d", (int)status);
        }
    }
}

- (void)primeRecordQueueBuffers {
    for (int i = 0; i < kSoundwaveRecorderNumBuffers; ++i) {
        OSStatus status = AudioQueueEnqueueBuffer(
                                                  recordQueue,            // AudioQueueRef
                                                  recordQueueBuffers[i],  // AudioQueueBufferRef
                                                  0,                      // inNumPacketDescs
                                                  NULL                    // AudioStreamPacketDescription
                                                  );
        if (status != noErr) {
            DDLogError(@"error in enqueuing buffer in audio queue, error status: %d", (int)status);
        }
    }
}

- (BOOL)isRecording {
    UInt32 propertyIsRunning = 0;
    UInt32 propertyDataSize = sizeof(UInt32);
    AudioQueueGetProperty(
                          recordQueue,                      // AudioQueueRef
                          kAudioQueueProperty_IsRunning,    // AudioQueuePropertyID
                          &propertyIsRunning,               // outData
                          &propertyDataSize                 // ioDataSize
                          );
    return propertyIsRunning != 0;
}

- (void)startRecording {
    if (self.isRecording) {
        return;
    }
    
    [self primeRecordQueueBuffers];
    OSStatus status = AudioQueueStart(
                                      recordQueue,    // AudioQueueRef
                                      NULL            // AudioTimeStamp
                                      );
    if (status != noErr) {
        DDLogError(@"error in starting audio queue, error status: %d", (int)status);
    }
}

- (void)stopRecording {
    if (!self.isRecording) {
        return;
    }
    
    OSStatus status = AudioQueueStop(
                                     recordQueue,     // AudioQueueRef
                                     true             // inImmediate
                                     );
    if (status != noErr) {
        DDLogError(@"error in stopping audio queue, error status: %d", (int)status);
    }
}

- (void)dealloc {
    OSStatus status = AudioQueueDispose(
                                        recordQueue,  // AudioQueueRef
                                        true          // inImmediate
                                        );
    if (status != noErr) {
        DDLogError(@"error in disposing audio queue, error status: %d", (int)status);
    }
}

@end
