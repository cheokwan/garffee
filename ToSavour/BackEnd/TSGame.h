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
    GamePlayResultProgress,
    GamePlayResultWin,
    GamePlayResultLose
} GamePlayResult;

@interface TSGame : NSObject<RKMappableObject>

@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *gameImageURL;
@property (nonatomic, strong) NSString *gamePackageURL;
@property (nonatomic, strong) NSString *gamePackageName;
@property (nonatomic, strong) NSString *gamePackageFullPath;
@property (nonatomic, strong) NSString *gamePackageUnzippedFullPath;
@property (nonatomic, strong) NSString *sponsorImageURL;
@property (nonatomic, strong) NSString *sponsorName;
@property (nonatomic, assign) NSInteger timeLimit;
@property (nonatomic, assign) NSInteger timePenalty;
@property (nonatomic, assign) NSInteger validNumberOfChanges;
@property (nonatomic, assign) GamePlayResult result;

@property (nonatomic, readonly) NSString *resolvedGameImageURL;
@property (nonatomic, readonly) NSString *resolvedGamePackageURL;
@property (nonatomic, readonly) NSString *resolvedSponsorImageURL;

@end
