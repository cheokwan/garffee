//
//  TSGamePlayHistory.h
//  ToSavour
//
//  Created by LAU Leung Yan on 21/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSGamePlayHistory : NSObject

@property (nonatomic, strong) NSString *historyId, *userId, *gameId, *result;
@property (nonatomic) NSDate *playedDate;

+(RKObjectMapping *)gamePlayHistoryRequestMapping;
+(RKObjectMapping *)gamePlayHistoryResponseMapping;

@end
