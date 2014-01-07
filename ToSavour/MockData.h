//
//  MockData.h
//  ToSavour
//
//  Created by LAU Leung Yan on 6/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

//  IMPORTANT: THIS CLASS IS EXCLUSIVELY USED TO DEBUG
//  NEED TO BE REMOVED FOR PRODUCTION

#import <Foundation/Foundation.h>

@interface MockData : NSObject

+ (void)mockBranches;
+ (void)removeAllBranches;

@end
