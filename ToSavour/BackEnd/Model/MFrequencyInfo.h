//
//  MFrequencyInfo.h
//  ToSavour
//
//  Created by Jason Wan on 4/3/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MFrequencyInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * frequencyBinLow;
@property (nonatomic, retain) NSNumber * frequencyBinHigh;
@property (nonatomic, retain) NSNumber * normalizedMagnitude;
@property (nonatomic, retain) NSDate * timestamp;

@end
