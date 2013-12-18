//
//  PhotoHuntManager.h
//  ToSavour
//
//  Created by LAU Leung Yan on 14/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TSGame.h"

#define CHANGE_GROUP_NONE           @"<NONE>"

typedef enum {
    PhotoHuntDidFinishOptionNone = 0,
    PhotoHuntDidFinishOptionWin,
    PhotoHuntDidFinishOptionLose
} PhotoHuntDidFinishOption;

typedef enum {
    PackageVerifyFailedOptionNone                   = 0,
    PackageVerifyFailedOptionNoChangesIsFound       = 1 << 0
} PackageVerifyFailedOption;

@class PhotoHuntManager;
@protocol PhotoHuntManagerDelegate <NSObject>
@optional
- (void)photoHuntManager:(PhotoHuntManager *)manager didFinishGameWithOption:(PhotoHuntDidFinishOption)option;
- (void)photoHuntManager:(PhotoHuntManager *)manager didFaiUnzipGame:(TSGame *)game;
- (void)photoHuntManager:(PhotoHuntManager *)manager didFailVerifyGame:(TSGame *)game reason:(PackageVerifyFailedOption)failOption;
@end

@interface PhotoHuntManager : NSObject

//@property (nonatomic, strong) NSString *packageName;
//@property (nonatomic, strong) NSString *packageFullPath;
@property (nonatomic, strong) TSGame *game;
@property (nonatomic, strong) NSDictionary *changesDictionary;
@property (nonatomic, strong) NSString *originalImageFullPath;
@property (nonatomic, strong) NSDictionary *buttonToChangeDict;
@property (nonatomic, strong) NSDictionary *changeToButtonsDict;
@property (nonatomic, assign) id<PhotoHuntManagerDelegate> delegate;

- (id)initWithGame:(TSGame *)game delegate:(id<PhotoHuntManagerDelegate>)delegate;
- (NSString *)changeGroupOfButtonIndex:(int)buttonIndex;
- (NSString *)gridButtonImageOfButtonIndex:(int)buttonIndex isOriginalImage:(BOOL)isOriginalImage;

//UI
- (void)changeIsFound:(NSString *)changeGroup;
- (BOOL)isChangeFound:(NSString *)changeGroup;
- (int)totalNumberOfChanges;
- (int)numberOfChangesFound;

@end
