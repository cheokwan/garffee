//
//  TSZipArchive.h
//  ToSavour
//
//  Created by LAU Leung Yan on 18/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "SSZipArchive.h"

@interface TSZipArchive : SSZipArchive

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination unzippedPath:(__strong NSString **)unzippedPath overwrite:(BOOL)overwrite password:(NSString *)password error:(NSError **)error delegate:(id<SSZipArchiveDelegate>)delegate;

@end
