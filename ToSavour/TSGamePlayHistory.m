//
//  TSGamePlayHistory.m
//  ToSavour
//
//  Created by LAU Leung Yan on 21/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TSGamePlayHistory.h"

#import "RestManager.h"

@interface TSGamePlayHistory ()
@property (nonatomic, strong) NSString *resultString;
@end

@implementation TSGamePlayHistory

+(RKObjectMapping *)gamePlayHistoryRequestMapping {
    return [self gamePlayHistoryMapping];
}

+(RKObjectMapping *)gamePlayHistoryResponseMapping {
    return [[self gamePlayHistoryMapping] inverseMapping];
}

+ (RKObjectMapping *)gamePlayHistoryMapping {
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{@"userId": @"UserId",
                                                  @"gameId": @"DailyGameId",
                                                  @"resultString": @"Result"
                                                  }];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

- (void)dealloc {
    self.historyId = nil;
    self.userId = nil;
    self.gameId = nil;
    self.result = nil;
    self.playedDate = nil;
}

@end
