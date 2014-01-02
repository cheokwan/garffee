//
//  DataFetchManager.h
//  ToSavour
//
//  Created by Jason Wan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataFetchManager : NSObject

+ (instancetype)sharedInstance;
- (void)fetchAddressBookContactsInContext:(NSManagedObjectContext *)context;

@end
