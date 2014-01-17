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

@interface DataFetchManager()
@property (nonatomic, assign)   ABAddressBookRef addressBook;
@property (nonatomic, assign)   CFArrayRef allABContacts;
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

- (void)fetchAddressBookContactsInContext:(NSManagedObjectContext *)context {
    // TODO: check if user has previously disallowed address book access, only retry a limited
    // number of times
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
        ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
            if (granted && !error) {
                [self fetchAddressBookContactsInContext:context];
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
        // TODO: generate in setters
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
            if (abUser.URLForProfileImage) {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtURL:abUser.URLForProfileImage error:&error];
                if (error) {
                    DDLogError(@"error removing old cached contact image %@: %@", abUser.URLForProfileImage, error);
                }
            }
            
            NSMutableString *fileName = [[abUser.name lowercaseString] mutableCopy];
            [fileName appendString:[@([[NSDate date] timeIntervalSinceReferenceDate]) stringValue]];
            [fileName replaceOccurrencesOfString:@" " withString:@"_" options:0 range:NSMakeRange(0, fileName.length)];
            if (fileName.length > 0) {
                NSString *filePath = [[[[AppDelegate sharedAppDelegate] addressBookUserImageCacheDirectory] path] stringByAppendingPathComponent:fileName];
                [imageData writeToFile:filePath atomically:NO];
                abUser.abProfileImageURL = filePath;
            }
        }
    }
    NSError *error = nil;
    [context save:&error];
    if (error) {
        DDLogError(@"error saving address book contacts: %@", error);
    }
}

- (void)discoverFacebookAppUsersInContext:(NSManagedObjectContext *)context {
    [[RestManager sharedInstance] queryFacebookContactsInContext:context handler:self];
}

- (void)discoverAddressBookAppUsersContext:(NSManagedObjectContext *)context {
    [[RestManager sharedInstance] queryAddressBookContactsInContext:context handler:self];
}

#pragma mark - RestManagerResponseHandler

- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(queryFacebookContactsInContext:handler:)) {
        RKMappingResult *mappingResult = userInfo[@"mappingResult"];
        if ([mappingResult isKindOfClass:RKMappingResult.class]) {
            // TODO: do it background maybe
            NSArray *mappedObjects = [mappingResult array];
            DDLogInfo(@"successfully query app friends with facebook contacts, %ld returned", mappedObjects.count);
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
            // TODO: do it background maybe
            NSArray *mappedObjects = [mappingResult array];
            DDLogInfo(@"successfully query app friends with address book contacts, %ld returned", mappedObjects.count);
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
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (selector == @selector(queryFacebookContactsInContext:handler:)) {
        DDLogError(@"failed to query app friends with facebook contacts: %@", error);
    } else if (selector == @selector(queryAddressBookContactsInContext:handler:)) {
        DDLogError(@"failed to query app friends with address book contacts: %@", error);
    }
}

- (void)dealloc {
    CFRelease(_addressBook);
    CFRelease(_allABContacts);
}

@end
