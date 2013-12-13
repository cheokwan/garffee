//
//  RKMappableEntity.h
//  ToSavour
//
//  Created by Jason Wan on 12/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RKMappableEntity <NSObject>
@required
+ (RKEntityMapping *)defaultEntityMapping;
+ (RKResponseDescriptor *)defaultResponseDescriptor;

@end
