//
//  TSLogFormatter.m
//  ToSavour
//
//  Created by Jason Wan on 28/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TSLogFormatter.h"

@interface TSLogFormatter()
@property (nonatomic, assign)   int loggerCount;
@property (nonatomic, retain)   NSDateFormatter *threadUnsafeDateFormatter;
@end

@implementation TSLogFormatter

- (id)init {
    self = [super init];
    if (self) {
        self.loggerCount = 0;
        self.threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
        [_threadUnsafeDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel = nil;
    switch (logMessage->logFlag) {
        case LOG_FLAG_ERROR:
            logLevel = @"E";
            break;
        case LOG_FLAG_WARN:
            logLevel = @"W";
            break;
        case LOG_FLAG_INFO:
            logLevel = @"I";
            break;
        case LOG_FLAG_DEBUG:
            logLevel = @"D";
            break;
        case LOG_FLAG_VERBOSE:
            logLevel = @"V";
            break;
    }
    NSString *timeStamp = [_threadUnsafeDateFormatter stringFromDate:logMessage->timestamp];
    return [NSString stringWithFormat:@"%@ %@[%@:%d][%@ %@] %@",
            timeStamp,
            logLevel,
            logMessage.threadID,
            logMessage->lineNumber,
            logMessage.fileName,
            logMessage.methodName,
            logMessage->logMsg];
}

- (void)didAddToLogger:(id<DDLogger>)logger {
    ++_loggerCount;
    NSAssert(_loggerCount <= 1, @"This logger isn't thread-safe");
}

- (void)willRemoveFromLogger:(id<DDLogger>)logger {
    --_loggerCount;
}

@end
