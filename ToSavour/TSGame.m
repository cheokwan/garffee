//
//  TSGame.m
//  ToSavour
//
//  Created by LAU Leung Yan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TSGame.h"

@implementation TSGame

- (void)dealloc {
    self.gameId = nil;
    self.name = nil;
    self.gameImageURL = nil;
    self.gamePackageURL = nil;
    self.gamePackageName = nil;
    self.gamePackageFullPath = nil;
    self.gamePackageUnzippedFullPath = nil;
}

@end