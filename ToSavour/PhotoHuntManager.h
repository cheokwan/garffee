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

@class PhotoHuntManager;
@protocol PhotoHuntManagerDelegate <NSObject>
-(void)photoHuntManager:(PhotoHuntManager *)manager didFinishGameWithOption:(PhotoHuntDidFinishOption)option;
@end

@interface PhotoHuntManager : NSObject

@property (nonatomic, assign) int validNumOfChanges;
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

- (void)changeIsFound:(NSString *)changeGroup;
- (BOOL)isChangeFound:(NSString *)changeGroup;

@end
