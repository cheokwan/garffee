//
//  TSGameDownloadManager.m
//  ToSavour
//
//  Created by LAU Leung Yan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TSGameDownloadManager.h"

#import <AFNetworking.h>

@interface TSGameDownloadManager ()
@end

@implementation TSGameDownloadManager

static TSGameDownloadManager *sharedInstance = nil;

+ (TSGameDownloadManager *)getInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[TSGameDownloadManager alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - game packages
- (void)downloadGamePackage:(NSString *)packageURL packageName:(NSString *)packageName success:(TSGameDownloadPackageResultCallback)successCallback failure:(TSGameDownloadPackageResultCallback)failureCallback progress:(TSGameDownloadPackageProgressCallback)progressCallback {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:packageURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        NSString *filePath = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSData *data = responseObject;
            filePath = [NSString stringWithFormat:@"%@/%@.zip", documentsDirectory, packageName];
            //XXX-ML
            filePath = [NSString stringWithFormat:@"%@/abc.zip", documentsDirectory, packageName];
            //XXX-ML
            [data writeToFile:filePath atomically:NO];
        }
        
        //XXX-ML
        filePath = [NSString stringWithFormat:@"/Users/maximum168/Library/Application Support/iPhone Simulator/7.0/Applications/58D7AFB2-F0DC-400C-B3C3-356AF3A5E44E/Documents/%@.zip", packageName];
        //XXX-ML
        
        if (successCallback) successCallback(filePath);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        DDLogError(@"Download game package fail: %@", error);
        if (failureCallback) failureCallback(nil);
    }];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (progressCallback) progressCallback(totalBytesRead, totalBytesExpectedToRead);
    }];
    [operation start];
}

@end
