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

@interface TimeTracker : NSObject <CLLocationManagerDelegate/*XXX, NSURLConnectionDelegate, NSURLConnectionDataDelegateXXX*/>

@property (nonatomic, readonly) BOOL trackingStarted;  // XXX
@property (nonatomic, readonly) NSTimeInterval latestApproxArrivalTime;
@property (nonatomic, weak)     MKMapView *delegateMapView;  // XXX

+ (TimeTracker *)sharedInstance;
- (void)startTrackingWithApproxDuration:(NSTimeInterval)duration;
- (void)stopTracking;
- (void)scheduleInBackground; // XXX
//- (void)scheduleInBackgroundLongPoll; // XXX
- (void)handleBackgroundFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler code:(NSString *)code;  // XXX

@end
