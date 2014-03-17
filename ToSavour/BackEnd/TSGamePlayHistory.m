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

+ (RKObjectMapping *)gamePlayHistoryRequestMapping {
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{@"userId":    @"UserId",
                                                  @"gameId":    @"DailyGameId",
                                                  @"result":    @"Result"
                                                  }];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

#pragma mark - RKMappableObject

+ (RKObjectMapping *)defaultObjectMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self.class];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":                @"historyId",
                                                  @"DailyGameId":       @"gameId",
                                                  @"UserId":            @"userId",
                                                  @"PlayedDateTime":    @"playedDate",
                                                  @"Result":            @"result"
                                                  }];
    mapping.valueTransformer = [RestManager sharedInstance].defaultDotNetValueTransformer;
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultObjectMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
