//
//  MapTrackingAnnotation.m
//  ToSavour
//
//  Created by Jason Wan on 3/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MapTrackingAnnotation.h"
#import "NSManagedObject+Helper.h"


@implementation MapTrackingAnnotation

@dynamic latitude;
@dynamic longitude;
@dynamic title;
@dynamic subtitle;
@dynamic serial;
@dynamic timestamp;
@dynamic estimatedRemainingTime;
@dynamic annotationType;


+ (NSDateFormatter *)dateFormatter {
    // XXX - non thread safe
    static dispatch_once_t onceToken = 0;
    static NSDateFormatter *_dateFormatter = nil;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd HH:mm:ss"];
    });
    return _dateFormatter;
}

+ (id)newAnnotationWithLocation:(CLLocationCoordinate2D)coordinate annotationType:(MapTrackingAnnotationType)annotationType inContext:(NSManagedObjectContext *)context {
    return [self newAnnotationWithLocation:coordinate annotationType:annotationType serial:0 estimatedRemainingTime:0.0 inContext:context];
}

+ (id)newAnnotationWithLocation:(CLLocationCoordinate2D)coordinate annotationType:(MapTrackingAnnotationType)annotationType serial:(NSInteger)serial estimatedRemainingTime:(NSTimeInterval)estimatedRemainingTime inContext:(NSManagedObjectContext *)context {
    MapTrackingAnnotation *annotation = (MapTrackingAnnotation *)[self.class newObjectInContext:context];
    annotation.coordinate = coordinate;
    annotation.serial = serial;
    annotation.timestamp = [[NSDate date] timeIntervalSinceReferenceDate];
    annotation.estimatedRemainingTime = estimatedRemainingTime;
    annotation.annotationType = annotationType;
    switch (annotationType) {
        case MapTrackingAnnotationTypeUpdate:
            annotation.title = @"Tracked Position";;
            break;
        case MapTrackingAnnotationTypeDestination:
             annotation.title = @"Final Destination";
            break;
        case MapTrackingAnnotationTypeBackground:
            annotation.title = @"";  // @"Background Activity"
            break;
    }
    return annotation;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.latitude = newCoordinate.latitude;
    self.longitude = newCoordinate.longitude;
}

//- (NSString *)title {
//    switch (self.annotationType) {
//        case MapTrackingAnnotationTypeUpdate:
//            return @"Tracked Position";
//            break;
//        case MapTrackingAnnotationTypeDestination:
//            return @"Final Destination";
//            break;
//        case MapTrackingAnnotationTypeBackground:
//            return @"Background Activity";
//            break;
//    }
//    return nil;
//}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"#%d <%.3f, %.3f> %@", self.serial, self.latitude, self.longitude, [self.class.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.timestamp]]];
}

@end
