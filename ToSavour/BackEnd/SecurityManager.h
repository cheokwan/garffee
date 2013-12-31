//
//  SecurityManager.h
//  ToSavour
//
//  Created by Jason Wan on 23/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *SecurityManagerIdAppToken  = @"AppToken";

@interface SecurityManager : NSObject

+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;

+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier;

+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

+ (void)deleteKeychainValue:(NSString *)identifier;

@end
