//
//  PhotoHuntManager.m
//  ToSavour
//
//  Created by LAU Leung Yan on 14/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "PhotoHuntManager.h"

#import <SSZipArchive.h>
#import "NSMutableArray+Shuffle.h"

#define CHANGE_IMAGE_EXTENSION      @"jpg"

@interface PhotoHuntManager ()
@property (nonatomic, strong) NSMutableDictionary *buttonToChangeMutableDict;
@property (nonatomic, strong) NSMutableDictionary *changeTobuttonsMutableDict;
@property (nonatomic, strong) NSMutableDictionary *changesValidDict;
@property (nonatomic, strong) NSMutableArray *foundChanges;
@property (nonatomic, strong) NSString *transImageFullPath;
@end

@implementation PhotoHuntManager
- (id)initWithPackageName:(NSString *)packageName delegate:(id<PhotoHuntManagerDelegate>)delegate {
    self = [self init];
    if (self) {
        self.delegate = delegate;
        self.packageName = packageName;
        self.foundChanges = [NSMutableArray array];
        if (![self unzipFile:_packageName extension:@"zip"]) {DDLogError(@"unzip failed: %@", _packageName);}
    }
    return self;
}

- (BOOL)unzipFile:(NSString *)fileName extension:(NSString *)extension {
    if (!fileName || !extension) {
        DDLogError(@"_filePackageName is nil");
        return NO;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@", documentsDirectory, fileName, extension];
    NSString *zipPath = filePath;
    
    return [SSZipArchive unzipFileAtPath:zipPath toDestination:documentsDirectory];
}

- (NSString *)packageFullPathFromPackageName:(NSString *)packageName {
    if (!packageName) {
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, packageName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fullPath]) {
        fullPath = nil;
    }
    return fullPath;
}

- (NSDictionary *)changesDictionary {
    if (!_changesDictionary) {
        self.changesDictionary = [self changesDictionaryWithPackageFullPath:[self packageFullPath]];
    }
    return _changesDictionary;
}

- (NSDictionary *)changesDictionaryWithPackageFullPath:(NSString *)packageFullPath {
    if (!packageFullPath) {
        return nil;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:packageFullPath error:&error];
    for (NSString *item in fileList) {
        BOOL isDir;
        NSString *itemFullPath = [NSString stringWithFormat:@"%@/%@", packageFullPath, item];
        [fileManager fileExistsAtPath:itemFullPath isDirectory:&isDir];
        if (isDir && [item hasPrefix:@"Change"]) {
            dict[item] = itemFullPath;
        } else {
            if ([item hasPrefix:@"trans"]) {
                self.transImageFullPath = itemFullPath;
            }
            DDLogCDebug(@"%@ is not a directory", item);
        }
    }
    self.changesValidDict = [NSMutableDictionary dictionary];
    NSMutableArray *keys = [dict.allKeys mutableCopy];
    [keys shuffle];
    for (int i=0; i<_validNumOfChanges; i++) {
        _changesValidDict[[keys objectAtIndex:i]] = @(YES);
    }
    return dict;
}

- (NSString *)originalImageFullPathFromPackageName:(NSString *)packageName {
    return [NSString stringWithFormat:@"%@/%@_org.jpg", [self packageFullPathFromPackageName:packageName], packageName];
}

- (NSDictionary *)buttonToChangeDict {
    if (!_buttonToChangeMutableDict) {
        [self generateButtonChangeDict];
    }
    return _buttonToChangeMutableDict;
}

- (NSDictionary *)changeToButtonsDict {
    if (!_changeTobuttonsMutableDict) {
        [self generateButtonChangeDict];
    }
    return _changeTobuttonsMutableDict;
}

- (void)generateButtonChangeDict {
    if (!_buttonToChangeMutableDict) {
        self.buttonToChangeMutableDict = [NSMutableDictionary dictionary];
    }
    if (!_changeTobuttonsMutableDict) {
        self.changeTobuttonsMutableDict = [NSMutableDictionary dictionary];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *keys = [self.changesDictionary allKeys];
    for (NSString *key in keys) {
        NSString *fullPath = _changesDictionary[key];
        error = nil;
        NSArray *fileList = [fileManager contentsOfDirectoryAtPath:fullPath error:&error];
        for (NSString *element in fileList) {
            NSString *prefix = [NSString stringWithFormat:@"%@_", _packageName];
            NSString *numberStr = [element stringByReplacingOccurrencesOfString:prefix withString:@""];
            NSString *extension = [NSString stringWithFormat:@".%@", CHANGE_IMAGE_EXTENSION];
            numberStr = [numberStr stringByReplacingOccurrencesOfString:extension withString:@""];
            int number = [numberStr intValue];
            _buttonToChangeMutableDict[@(number)] = key;
            NSMutableArray *buttons = _changeTobuttonsMutableDict[key];
            if (!buttons) {
                buttons = [NSMutableArray array];
                [buttons addObject:@(number)];
                _changeTobuttonsMutableDict[key] = buttons;
            } else {
                [buttons addObject:@(number)];
            }
        }
    }
}

#pragma mark - UI related
- (void)changeIsFound:(NSString *)changeGroup {
    [_foundChanges addObject:changeGroup];
    NSSet *allKeysSet = [NSSet setWithArray:self.changesValidDict.allKeys];
    NSSet *allFoundChangesSet = [NSSet setWithArray:_foundChanges];
    if ([allFoundChangesSet isEqualToSet:allKeysSet]) {
        if ([_delegate respondsToSelector:@selector(photoHuntManager:didFinishGameWithOption:)]) {
            [_delegate photoHuntManager:self didFinishGameWithOption:PhotoHuntDidFinishOptionWin];
        }
    }
}

- (BOOL)isChangeFound:(NSString *)changeGroup {
    return [_foundChanges containsObject:changeGroup];
}

- (NSString *)packageFullPath {
    if (!_packageFullPath) {
        self. packageFullPath = [self packageFullPathFromPackageName:_packageName];
    }
    return _packageFullPath;
}

- (NSString *)changeGroupOfButtonIndex:(int)buttonIndex {
    NSString *groupKey = CHANGE_GROUP_NONE;
    if (self.buttonToChangeDict[@(buttonIndex)]) {
        NSString *key = self.buttonToChangeDict[@(buttonIndex)];
        if ([_changesValidDict.allKeys containsObject:key]) {
            //check if this change key is in current game as we may want to limit the number of changes per game
            groupKey = key;
        }
    }
    return groupKey;
}

- (NSString *)originalImageFullPath {
    return [self originalImageFullPathFromPackageName:_packageName];
}

- (NSString *)gridButtonImageOfButtonIndex:(int)buttonIndex isOriginalImage:(BOOL)isOriginalImage {
    NSString *imagePath = self.transImageFullPath;
    if (isOriginalImage) {
        return imagePath;
    }
    NSString *group = self.buttonToChangeDict[@(buttonIndex)];
    if (group) {
        NSString *groupPath = nil;
        if ((groupPath = self.changesDictionary[group])) {
            NSString *prefix = [NSString stringWithFormat:@"%@_", _packageName];
            NSString *extension = [NSString stringWithFormat:@".%@", CHANGE_IMAGE_EXTENSION];
            imagePath = [NSString stringWithFormat:@"%@/%@%d%@", groupPath, prefix, buttonIndex, extension];
        }
    }
    return imagePath;
}

@end
