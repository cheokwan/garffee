//
//  MapTrackingAnnotation.h
//  ToSavour
//
//  Created by Jason Wan on 3/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>


typedef enum {
    MapTrackingAnnotationTypeUpdate = 0,
    MapTrackingAnnotationTypeDestination,
    MapTrackingAnnotationTypeActivity,
} MapTrackingAnnotationType;

@interface MapTrackingAnnotation : NSManagedObject<MKAnnotation>

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic) int32_t serial;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic) NSTimeInterval estimatedRemainingTime;
@property (nonatomic) int32_t annotationType;
@property (nonatomic) double accuracy;
@property (nonatomic) double remainingDistance;


+ (id)newAnnotationWithLocation:(CLLocationCoordinate2D)coordinate annotationType:(MapTrackingAnnotationType)annotationType inContext:(NSManagedObjectContext *)context;
+ (id)newAnnotationWithLocation:(CLLocationCoordinate2D)coordinate annotationType:(MapTrackingAnnotationType)annotationType serial:(NSInteger)serial accuracy:(double)accuracy remainingDistance:(CLLocationDistance)remainingDistance estimatedRemainingTime:(NSTimeInterval)estimatedRemainingTime inContext:(NSManagedObjectContext *)context;

@end
