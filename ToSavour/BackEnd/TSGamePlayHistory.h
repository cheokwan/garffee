//
//  TSGamePlayHistory.h
//  ToSavour
//
//  Created by LAU Leung Yan on 21/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSGamePlayHistory : NSObject<RKMappableObject>

@property (nonatomic, strong) NSString *historyId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) NSDate *playedDate;

+(RKObjectMapping *)gamePlayHistoryRequestMapping;

@end
