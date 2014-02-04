//
//  NSURL+Helper.h
//  ToSavour
//
//  Created by Jason Wan on 28/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Helper)

- (NSURL *)cacheData:(NSData *)data baseFileName:(NSString *)baseFileName originalCacheURL:(NSURL *)originalCacheURL;

- (NSURL *)filePathForCacheWithBaseFileName:(NSString *)baseFileName;

@end
