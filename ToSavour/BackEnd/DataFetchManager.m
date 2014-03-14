//
//  DataFetchManager.m
//  ToSavour
//
//  Created by Jason Wan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "DataFetchManager.h"
#import <AddressBook/AddressBook.h>
#import "TSModelIncludes.h"
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface DataFetchManager()
@property (nonatomic, assign)   ABAddressBookRef addressBook;
@property (nonatomic, assign)   CFArrayRef allABContacts;

@property (nonatomic, strong)   NSMutableArray *dummyImageViews;
@property (nonatomic, strong)   NSMutableDictionary *fetchSelectorRetriesMap;
@end

@implementation DataFetchManager

+ (instancetype)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static id instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSMutableArray *)dummyImageViews {
    if (!_dummyImageViews) {
        self.dummyImageViews = [NSMutableArray array];
    }
    return _dummyImageViews;
}

- (ABAddressBookRef)addressBook {
    if (!_addressBook) {
        CFErrorRef error = nil;
        self.addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        if (error) {
            DDLogError(@"error in creating address book: %@", error);
            self.addressBook = nil;
        }
    }
    return _addressBook;
}

- (CFArrayRef)allABContacts {
    if (!_allABContacts && self.addressBook) {
        self.allABContacts = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    }
    return _allABContacts;
}

- (NSMutableDictionary *)fetchSelectorRetriesMap {
    if (!_fetchSelectorRetriesMap) {
        self.fetchSelectorRetriesMap = [NSMutableDictionary dictionary];
    }
    return _fetchSelectorRetriesMap;
}

- (void)fetchAddressBookContactsInContext:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler {
    // TODO: check if user has previously disallowed address book access, only retry a limited
    // number of times
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
        ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
            if (granted && !error) {
                [self fetchAddressBookContactsInContext:context handler:handler];
            } else {
                DDLogError(@"error in requesting access to address book, granted: %@, %@", @(granted), error);
            }
        });
        return;
    }
    
    for (int i = 0; i < CFArrayGetCount(self.allABContacts); ++i) {
        ABRecordRef recordRef = CFArrayGetValueAtIndex(_allABContacts, i);
        
        ABRecordID recordID = ABRecordGetRecordID(recordRef);
        if (recordID == kABRecordInvalidID) {
            // skip this contact
            continue;
        }
        
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(recordRef, kABPersonFirstNameProperty));
        NSString *lastName = CFBridgingRelease(ABRecordCopyValue(recordRef, kABPersonLastNameProperty));
        NSDate *birthday = CFBridgingRelease(ABRecordCopyValue(recordRef, kABPersonBirthdayProperty));
        
        ABMultiValueRef emailsRef = ABRecordCopyValue(recordRef, kABPersonEmailProperty);
        NSArray *emails = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(emailsRef));
        CFRelease(emailsRef);
        NSString *email = [emails commaSeparatedString];
        
        ABMultiValueRef phonesRef = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
        NSArray *phones = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phonesRef));
        CFRelease(phonesRef);
        NSString *phonesString = [phones commaSeparatedString];
        
        if ([phonesString trimmedWhiteSpaces].length == 0) {
            // skip contacts who don't have any phone number
            continue;
        }
        // canonize the phone numbers and store them
        NSMutableArray *canonPhones = [NSMutableArray array];
        [phones enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *number = (NSString *)obj;
            NSString *canonNumber = [number canonicalPhoneNumber];
            if (canonNumber.length > 0) {
                [canonPhones addObject:canonNumber];
            }
        }];
        NSString *canonPhonesString = [canonPhones commaSeparatedString];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"abContactID = %@", @(recordID)];
        MUserAddressBookInfo *abUser = (MUserAddressBookInfo *)[MUserAddressBookInfo existingOrNewObjectInContext:context withPredicate:predicate];
        abUser.abContactID = @(recordID);
        abUser.abFirstName = firstName;
        abUser.abLastName = lastName;
        abUser.abBirthday = birthday;
        abUser.abEmail = email;
        abUser.abPhoneNumbers = phonesString;
        abUser.abCanonicalPhoneNumbers = canonPhonesString;
        
        NSData *imageData = (NSData *)CFBridgingRelease(ABPersonCopyImageData(recordRef));
        if (imageData) {
            NSURL *cacheURL = [[[AppDelegate sharedAppDelegate] addressBookUserImageCacheDirectory] cacheData:imageData baseFileName:abUser.name originalCacheURL:abUser.URLForProfileImage];
            if (cacheURL) {
                abUser.abProfileImageURL = cacheURL.path;
            }
        }
    }
    NSError *error = nil;
    [context save:&error];
    if (error) {
        DDLogError(@"error saving address book contacts: %@", error);
    }
}

- (void)discoverFacebookAppUsersInContext:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler {
    [[RestManager sharedInstance] queryFacebookContactsInContext:context handler:self];
}

- (void)discoverAddressBookAppUsersContext:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler {
    [[RestManager sharedInstance] queryAddressBookContactsInContext:context handler:self];
}

- (void)cacheLocalProductImages:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler {
    NSFetchRequest *productFetchRequest = [MProductInfo fetchRequest];
    NSFetchRequest *choiceFetchRequest = [MProductOptionChoice fetchRequest];
    NSFetchRequest *branchFetchRequest = [MBranch fetchRequest];
    NSError *error = nil;
    NSArray *products = [context executeFetchRequest:productFetchRequest error:&error];
    if (error) {
        DDLogError(@"error fetching products: %@", error);
    }
    error = nil;
    NSArray *choices = [context executeFetchRequest:choiceFetchRequest error:&error];
    if (error) {
        DDLogError(@"error fetching option choices: %@", error);
    }
    error = nil;
    NSArray *branches = [context executeFetchRequest:branchFetchRequest error:&error];
    if (error) {
        DDLogError(@"error fetching store branches: %@", error);
    }
    
    NSMutableArray *allItems = [NSMutableArray array];
    [allItems addObjectsFromArray:products];
    [allItems addObjectsFromArray:choices];
    [allItems addObjectsFromArray:branches];
    [self.dummyImageViews removeAllObjects];
    
    __block NSMutableArray *errors = [NSMutableArray array];
    __block NSInteger errorCount = 0;
    for (id item in allItems) {
        if ([item respondsToSelector:@selector(resolvedImageURL)] &&
            [item resolvedImageURL]) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [_dummyImageViews addObject:imageView];  // retain the imageView
            
            NSURL *imageURL = [item localCachedImageURL] ? [NSURL fileURLWithPath:[item localCachedImageURL]] : [NSURL URLWithString:[item resolvedImageURL]];  // disable second time image fetch for now, if image already cached in storage, don't download again
            
            __weak UIImageView *weakImageView = imageView;
            [imageView setImageWithURL:imageURL placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                NSData *imageData = nil;
                if (image) {
                    if ([[[item resolvedImageURL] lowercaseString] hasSuffix:@".jpg"]) {
                        imageData = UIImageJPEGRepresentation(image, 0.8);
                    } else {
                        imageData = UIImagePNGRepresentation(image);
                    }
                }
                if (imageData.length > 0) {
                    NSURL *originalCacheURL = [item localCachedImageURL] ? [NSURL fileURLWithPath:[item localCachedImageURL]] : nil;
                    NSURL *newCacheURL = [[[AppDelegate sharedAppDelegate] productImageCacheDirectory] cacheData:imageData baseFileName:[[item resolvedImageURL] lastPathComponent] originalCacheURL:originalCacheURL];
                    if (newCacheURL) {
                        [item setLocalCachedImageURL:newCacheURL.path];
                        DDLogInfo(@"successfully downloaded and cached product image %@ to path: %@", [item resolvedImageURL], newCacheURL);
                    }
                } else {
                    DDLogError(@"error downloading product image at path %@: %@", [item resolvedImageURL], error);
                    ++errorCount;
                    [errors addObject:error];
                }
                [_dummyImageViews removeObject:weakImageView];
                if (_dummyImageViews.count == 0) {
                    [context save];
                    if (errors.count == 0 && [handler respondsToSelector:@selector(dataFetchManagerService:succeededWithUserInfo:)]) {
                        [handler dataFetchManagerService:_cmd succeededWithUserInfo:nil];
                    } else if (errors.count > 0 && [handler respondsToSelector:@selector(dataFetchManagerService:failedWithError:userInfo:)]) {
                        [handler dataFetchManagerService:_cmd failedWithError:[errors firstObject] userInfo:@{@"errors": errors, @"errorCount": @(errorCount)}];
                    }
                }
            }];
        }
    }
}

- (void)performRestManagerFetch:(SEL)fetchSelector retries:(NSInteger)retries {
    self.fetchSelectorRetriesMap[NSStringFromSelector(fetchSelector)] = @(retries - 1);
    [[RestManager sharedInstance] performSelector:fetchSelector withObject:self];  // wtf is this compiler warning
}

#pragma mark - RestManagerResponseHandler

- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(queryFacebookContactsInContext:handler:)) {
        RKMappingResult *mappingResult = userInfo[@"mappingResult"];
        if ([mappingResult isKindOfClass:RKMappingResult.class]) {
            NSArray *mappedObjects = [mappingResult array];
            DDLogInfo(@"successfully query app friends with facebook contacts, %d returned", (int)mappedObjects.count);
            for (KVPair *pair in mappedObjects) {
                if (![pair isKindOfClass:KVPair.class]) {
                    continue;
                }
                NSString *facebookID = pair.value;
                NSString *appID = pair.key;
                NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"fbID = %@", facebookID];
                MUserFacebookInfo *existingUser = facebookID.length > 0
                ? (MUserFacebookInfo *)[MUserFacebookInfo existingObjectInContext:[AppDelegate sharedAppDelegate].managedObjectContext withPredicate:fetchPredicate]
                : nil;
                if (existingUser && !existingUser.appID && appID.length > 0) {
                    // TODO: if this appID fetches an existing object, e.g. MUserFacebookInfo or MUserAddressBookInfo
                    // need to merge them; or just delete this existingUser and re-fetch MUserInfo
                    existingUser.appID = appID;
                }
            }
            [[AppDelegate sharedAppDelegate].managedObjectContext save];
        }
    } else if (selector == @selector(queryAddressBookContactsInContext:handler:)) {
        RKMappingResult *mappingResult = userInfo[@"mappingResult"];
        if ([mappingResult isKindOfClass:RKMappingResult.class]) {
            NSArray *mappedObjects = [mappingResult array];
            DDLogInfo(@"successfully query app friends with address book contacts, %d returned", (int)mappedObjects.count);
            for (KVPair *pair in mappedObjects) {
                if (![pair isKindOfClass:KVPair.class]) {
                    continue;
                }
                NSString *phoneNumber = [pair.value canonicalPhoneNumber];
                NSString *appID = pair.key;
                NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"abCanonicalPhoneNumbers CONTAINS %@", phoneNumber];  // TODO: do more rigorous check, this has potential bug
                MUserAddressBookInfo *existingUser = phoneNumber.length > 0
                ? (MUserAddressBookInfo *)[MUserAddressBookInfo existingObjectInContext:[AppDelegate sharedAppDelegate].managedObjectContext withPredicate:fetchPredicate]
                : nil;
                if (existingUser && !existingUser.appID && appID.length > 0) {
                    // TODO: if this appID fetches an existing object, e.g. MUserFacebookInfo or MUserAddressBookInfo
                    // need to merge them; or just delete this existingUser and re-fetch MUserInfo
                    existingUser.appID = appID;
                }
            }
            [[AppDelegate sharedAppDelegate].managedObjectContext save];
        }
    } else {
        DDLogInfo(@"succefully perform RestManager fetch: %@", NSStringFromSelector(selector));
        if (self.fetchSelectorRetriesMap[NSStringFromSelector(selector)]) {
            [self.fetchSelectorRetriesMap removeObjectForKey:NSStringFromSelector(selector)];
        }
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(queryFacebookContactsInContext:handler:)) {
        DDLogError(@"failed to query app friends with facebook contacts: %@", error);
    } else if (selector == @selector(queryAddressBookContactsInContext:handler:)) {
        DDLogError(@"failed to query app friends with address book contacts: %@", error);
    } else {
        DDLogWarn(@"failed to perform RestManager fetch: %@ - %@", NSStringFromSelector(selector), error);
        NSNumber *retriesCount = self.fetchSelectorRetriesMap[NSStringFromSelector(selector)];
        if (retriesCount && [retriesCount intValue] > 0) {
            DDLogWarn(@"retrying %@ for %@ more time", NSStringFromSelector(selector), retriesCount);
            [self performRestManagerFetch:selector retries:[retriesCount intValue]];
        } else if ([retriesCount intValue] <= 0) {
            [self.fetchSelectorRetriesMap removeObjectForKey:NSStringFromSelector(selector)];
        }
    }
}

- (void)dealloc {
    CFRelease(_addressBook);
    CFRelease(_allABContacts);
}

@end
