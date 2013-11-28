//
//  Essentials.h
//  ToSavour
//
//  Created by Jason Wan on 28/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#ifndef ToSavour_Essentials_h
#define ToSavour_Essentials_h

#import <CocoaLumberjack/DDLog.h>

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

#endif
