//
//  NSURL+Helper.m
//  ToSavour
//
//  Created by Jason Wan on 28/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "NSURL+Helper.h"

@implementation NSURL (Helper)

- (NSURL *)cacheData:(NSData *)data baseFileName:(NSString *)baseFileName originalCacheURL:(NSURL *)originalCacheURL {
    BOOL isDirectory = NO;
    BOOL isPathExisted = [[NSFileManager defaultManager] fileExistsAtPath:self.path isDirectory:&isDirectory];
    if (data && baseFileName && isDirectory && isPathExisted) {
        NSURL *cacheFileURL = [self filePathForCacheWithBaseFileName:baseFileName];
        if (cacheFileURL) {
            BOOL success = [data writeToFile:cacheFileURL.path atomically:YES];
            if (success) {
                if (originalCacheURL && [[NSFileManager defaultManager] fileExistsAtPath:originalCacheURL.path]) {
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:originalCacheURL.path error:&error];
                    if (error) {
                        DDLogError(@"error removing old cached data at path %@: %@", originalCacheURL.path, error);
                    }
                }
                return cacheFileURL;
            } else {
                DDLogError(@"error caching data at path: %@", cacheFileURL);
            }
        }
    }
    return nil;
}

- (NSURL *)filePathForCacheWithBaseFileName:(NSString *)baseFileName {
    BOOL isDirectory = NO;
    BOOL isPathExisted = [[NSFileManager defaultManager] fileExistsAtPath:self.path isDirectory:&isDirectory];
    if (baseFileName && isDirectory && isPathExisted) {
        // TODO: may be construct the name better to retain file extension
        NSMutableString *fileName = [[baseFileName lowercaseString] mutableCopy];
        [fileName appendString:[@([[NSDate date] timeIntervalSinceReferenceDate]) stringValue]];
        [fileName replaceOccurrencesOfString:@" " withString:@"_" options:0 range:NSMakeRange(0, fileName.length)];
        
        NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
        NSInteger collisionCount = 1;
        while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            filePath = [[self.path stringByAppendingPathComponent:fileName] stringByAppendingString:[@(collisionCount) stringValue]];
            ++collisionCount;
        }
        return [NSURL fileURLWithPath:filePath isDirectory:NO];
    }
    return nil;
}

@end
