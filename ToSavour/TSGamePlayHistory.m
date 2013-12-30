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

+(RKObjectMapping *)updateGamePlayHistoryRequestMapping {
    return [[self gamePlayHistoryResponseMapping] inverseMapping];
}

+ (RKResponseDescriptor *)gamePlayHistoryResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self gamePlayHistoryResponseMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}
+ (RKObjectMapping *)gamePlayHistoryResponseMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{@"UserId": @"userId",
                                                  @"DailyGameId": @"gameId",
                                                  @"Result": @"result",
                                                  @"PlayedDateTime" : @"playedDate",
                                                  @"Id" : @"historyId"
                                                  }];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

+ (RKObjectMapping *)gamePlayHistoryRequestMapping {
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{@"userId": @"UserId",
                                                  @"gameId": @"DailyGameId",
                                                  @"result": @"Result"
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
