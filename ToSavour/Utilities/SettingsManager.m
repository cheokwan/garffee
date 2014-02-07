//
//  SettingsManager.m
//  ToSavour
//
//  Created by Jason Wan on 7/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "SettingsManager.h"

@implementation SettingsManager

+ (id)readSettingsValueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)writeSettingsValue:(id)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
