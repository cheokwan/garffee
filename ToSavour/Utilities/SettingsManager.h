//
//  SettingsManager.h
//  ToSavour
//
//  Created by Jason Wan on 7/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *SettingsManagerKeyRegistrationComplete = @"RegistrationCompleted";

@interface SettingsManager : NSObject

+ (id)readSettingsValueForKey:(NSString *)key;

+ (void)writeSettingsValue:(id)value forKey:(NSString *)key;

@end
