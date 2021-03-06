//
//  MBranch.m
//  ToSavour
//
//  Created by LAU Leung Yan on 7/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "MBranch.h"
#import "MGlobalConfiguration.h"
#import "RestManager.h"

@implementation MBranch

@dynamic address;
@dynamic branchId;
@dynamic closeTime;
@dynamic latitude;
@dynamic longitude;
@dynamic name;
@dynamic openTime;
@dynamic phoneNumber;
@dynamic region;
@dynamic thumbnailURL;
@dynamic imageURL;
@dynamic localCachedImageURL;

- (NSURL *)URLForThumbnailImage {
    return [self URLForImageRepresentation];  // TODO: replace with a real thumbnail image
}

- (NSURL *)URLForImage {
    return [self URLForImageRepresentation];
}

- (NSURL *)URLForImageRepresentation {
    if (self.localCachedImageURL.length > 0) {
        return [NSURL fileURLWithPath:self.localCachedImageURL];
    } else if (self.resolvedImageURL.length > 0) {
        return [NSURL URLWithString:self.resolvedImageURL];
    }
    return nil;
}

- (NSString *)resolvedImageURL {
//    return [[MGlobalConfiguration cachedBlobHostName] stringByAppendingPathComponent:self.imageURL];
    // XXX-STUB: stub for branch image, TODO: remove when server returns sane data
    return @"http://static6.businessinsider.com/image/4f5691296bb3f7920700005b/starbucks-concept-store.jpg";
}

- (NSNumber *)latitude {
//    return self.latitude;
    return @(22.281847);  // XXX-STUB: stub for branch latitude, TODO: remove when server returns sane data
}

- (NSNumber *)longitude {
//    return self.longitude;
    return @(114.185103);  // XXX-STUB: stub for branch longitude, TODO: remove when server returns sane data
}

# pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Address":                   @"address",
                                                  @"CloseHour":                 @"closeTime",
                                                  @"ContactNumber":             @"phoneNumber",
                                                  @"Id":                        @"branchId",
                                                  @"ImageUrl":                  @"imageURL",
                                                  @"Latitude":                  @"latitude",
                                                  @"Longitude":                 @"longitude",
                                                  @"Name":                      @"name",
                                                  @"OpenHour":                  @"openTime",
                                                  @"ThumbnailImageUrl":         @"thumbnailURL"
                                                  }];
    mapping.identificationAttributes = @[@"branchId"];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
