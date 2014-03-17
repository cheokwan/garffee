//
//  SecurityManager.h
//  ToSavour
//
//  Created by Jason Wan on 23/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *SecurityManagerIdAppToken  = @"AppToken";

/**
 *  SecurityManager
 *
 *  - Responsible for reading/writing app sensitive data securely with Apple
 *    keychain service. e.g. the app authentication token
 */
@interface SecurityManager : NSObject

/**
 *  Initialize a base search dictionary with the given identifier for locating
 *  a keychain item
 *
 *  @param identifier - the identifier to initialize the search dictionary with
 *  @return the initialized search dictionary
 */
+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;

/**
 *  Search and return the keychain item matching the identifier
 *
 *  @param identifier - the identifier to locate the keychain item
 *  @return the data for the keychain item found
 */
+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier;

/**
 *  Create a new keychain item with the give identifier
 *
 *  @param value - the value of the keychain item associated with the identifier
 *  @param identifier - the identifier for the new keychain item to be created
 *  @return YES on success, NO otherwise
 */
+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

/**
 *  Update the value of a keychain item with the given identifier
 *
 *  @param value - the new value of the keychain item
 *  @param identifier - the identifier for the keychain item to be udpated
 *  @return YES on success, NO otherwise
 */
+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

/**
 *  Delete the keychain item with the given identifier
 *
 *  @param identifier - the identifier for the keychain item to be deleted
 */
+ (void)deleteKeychainValue:(NSString *)identifier;

@end
