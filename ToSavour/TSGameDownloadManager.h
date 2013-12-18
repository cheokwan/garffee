//
//  TSGameDownloadManager.h
//  ToSavour
//
//  Created by LAU Leung Yan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TSGameDownloadPackageResultCallback)(NSString *packageFullPath);
typedef void (^TSGameDownloadPackageProgressCallback)(long long currentBytesRead, long long expectedTotalBytesRead);

@interface TSGameDownloadManager : NSObject

+ (TSGameDownloadManager *)getInstance;

- (void)downloadGamePackage:(NSString *)packageURL packageName:(NSString *)packageName success:(TSGameDownloadPackageResultCallback)successCallback failure:(TSGameDownloadPackageResultCallback)failureCallback progress:(TSGameDownloadPackageProgressCallback)progressCallback;

@end
