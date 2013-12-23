//
//  SecurityManager.m
//  ToSavour
//
//  Created by Jason Wan on 23/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "SecurityManager.h"
#import <Security/Security.h>

@implementation SecurityManager

static const NSString *serviceName = @"com.nbition.app.security";

+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    // Add search attributes
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Add search return types
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef cf_result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary,
                                          &cf_result);
    return status == errSecSuccess ? CFBridgingRelease(cf_result) : nil;
}

+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:valueData forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    return status == errSecSuccess ? YES : NO;
}

+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier {
    
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:valueData forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
    
    return status == errSecSuccess ? YES : NO;
}

+ (void)deleteKeychainValue:(NSString *)identifier {
    
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
}


@end
