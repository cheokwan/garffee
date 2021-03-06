//
//  TimeTracker.h
//  ToSavour
//
//  Created by Jason Wan on 25/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

typedef enum {
    TimeTrackerStateStopped = 0,
    TimeTrackerStateStarted,
    TimeTrackerStateBackgrounded,   // started but in background
} TimeTrackerState;

@interface TimeTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic, readonly) TimeTrackerState trackerState;
@property (nonatomic, weak)     MKMapView *delegateMapView;

+ (TimeTracker *)sharedInstance;
- (void)startTrackingWithDestinationCoordinate:(CLLocationCoordinate2D)destinationCoordinate;
- (void)stopTracking;
- (void)scheduleInBackground;
- (void)backToForeground;
- (void)handleBackgroundFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler code:(NSString *)code;

@end
