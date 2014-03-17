//
//  TSGame.m
//  ToSavour
//
//  Created by LAU Leung Yan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TSGame.h"
#import "MGlobalConfiguration.h"

@implementation TSGame

- (void)initialize {
    self.result = GamePlayResultNone;
    self.validNumberOfChanges = 5;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (NSString *)resolvedGameImageURL {
    return [[MGlobalConfiguration cachedBlobHostName] stringByAppendingPathComponent:self.gameImageURL];
}

- (NSString *)resolvedGamePackageURL {
    return [[MGlobalConfiguration cachedBlobHostName] stringByAppendingPathComponent:self.gamePackageURL];
}

- (NSString *)resolvedSponsorImageURL {
    return [[MGlobalConfiguration cachedBlobHostName] stringByAppendingPathComponent:self.sponsorImageURL];
}

#pragma mark - RKMappableObject

+ (RKObjectMapping *)defaultObjectMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self.class];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":                @"gameId",
                                                  @"Name":              @"name",
                                                  @"GameImageUrl":      @"gameImageURL",
                                                  @"GamePackageUrl":    @"gamePackageURL",
                                                  @"SponsorImageUrl":   @"sponsorImageURL",
                                                  @"SponsorName":       @"sponsorName",
                                                  @"TimeLimit":         @"timeLimit"
                                                  }];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultObjectMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end