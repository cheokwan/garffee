//
//  TimeTracker.h
//  ToSavour
//
//  Created by Jason Wan on 25/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TimeTracker : NSObject <CLLocationManagerDelegate/*XXX, NSURLConnectionDelegate, NSURLConnectionDataDelegateXXX*/>

@property (nonatomic, readonly) NSTimeInterval latestApproxArrivalTime;

+ (TimeTracker *)sharedInstance;
- (void)startTrackingWithApproxDuration:(NSTimeInterval)duration;
- (void)endTracking;
- (void)scheduleInBackground; // XXX
//- (void)scheduleInBackgroundLongPoll; // XXX
- (void)handleBackgroundFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler code:(NSString *)code;  // XXX

@end
