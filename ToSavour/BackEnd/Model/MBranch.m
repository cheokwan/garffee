//
//  MBranch.m
//  ToSavour
//
//  Created by LAU Leung Yan on 7/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "MBranch.h"

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

- (NSURL *)URLForThumbnailImage {
    if ([self.thumbnailURL trimmedWhiteSpaces].length > 0) {
//        return [NSURL URLWithString:self.thumbnailURL];
        return [NSURL URLWithString:@"http://static6.businessinsider.com/image/4f5691296bb3f7920700005b/starbucks-concept-store.jpg"]; // XXXXXX
    } else {
        return nil;
    }
}

- (NSURL *)URLForImage {
    if ([self.imageURL trimmedWhiteSpaces].length > 0) {
        return [NSURL URLWithString:@"http://static6.businessinsider.com/image/4f5691296bb3f7920700005b/starbucks-concept-store.jpg"]; // XXXXXX
    } else {
        return nil;
    }
}

- (NSNumber *)latitude {
    return @(22.281847);  // XXXXXX
}

- (NSNumber *)longitude {
    return @(114.185103);  // XXXXXX
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
