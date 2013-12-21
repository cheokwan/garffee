//
//  TSGame.h
//  ToSavour
//
//  Created by LAU Leung Yan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GamePlayResultNone = 0,
    GamePlayResultWin,
    GamePlayResultLose
} GamePlayResult;

@interface TSGame : NSObject

@property (nonatomic, strong) NSString *gameId, *name, *gameImageURL, *gamePackageURL, *gamePackageName, *gamePackageFullPath, *gamePackageUnzippedFullPath;
@property (nonatomic) int timeLimit, timePenalty;
@property (nonatomic) int validNumberOfChanges;
@property (nonatomic) GamePlayResult result;

@end
