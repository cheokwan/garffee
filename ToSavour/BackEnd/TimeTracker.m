//
//  TimeTracker.m
//  ToSavour
//
//  Created by Jason Wan on 25/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TimeTracker.h"
#import <CoreLocation/CoreLocation.h>
#import "TSSettings.h"
#import "AppDelegate.h"
#import "MapTrackingAnnotation.h"

// combine CoreLocation, BLE iBeacon, UltraSound locationing, Wifi fingerprinting/probing,
// motion activity, user reporting etc in approximating user arrival time

@interface TimeTracker()

@property (nonatomic, strong)   CLLocationManager *locationManager;
// properties that need to be reset between sessions
@property (nonatomic, strong)   CLLocation *destinationLocation;
@property (nonatomic, strong)   CLLocation *lastUpdatedLocation;

@property (nonatomic, strong)   NSTimer *timer;
@property (nonatomic, assign)   NSInteger showCount;
@property (nonatomic, assign)   __block UIBackgroundTaskIdentifier bgTaskId;

@end


@implementation TimeTracker
@synthesize trackerState = _trackerState;

+ (TimeTracker *)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static TimeTracker *instance = nil;  // __strong is default already
    dispatch_once(&token, ^{
        instance = [[TimeTracker alloc] init];
    });
    return instance;
}

- (void)initialize {
    self.locationManager = [[CLLocationManager alloc] init];
    _trackerState = TimeTrackerStateStopped;
    [self reset];
}

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (TimeTrackerState)trackerState {
    if (_trackerState == TimeTrackerStateStarted &&
        [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        _trackerState = TimeTrackerStateBackgrounded;
    }
    if (_trackerState == TimeTrackerStateBackgrounded
        && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        _trackerState = TimeTrackerStateStarted;
    }
    return _trackerState;
}

- (void)reset {
    self.destinationLocation = nil;
    self.lastUpdatedLocation = nil;
    _showCount = 0;
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.distanceFilter = 100;  // meters
    _locationManager.pausesLocationUpdatesAutomatically = YES;
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;  // TODO: make it dynamic
}

- (void)startTrackingWithDestinationCoordinate:(CLLocationCoordinate2D)destinationCoordinate {
    [self reset];
    
    if ([[TSSettings sharedInstance] isLocationServiceAvailable]) {
        self.destinationLocation = [[CLLocation alloc] initWithCoordinate:destinationCoordinate altitude:0.0 horizontalAccuracy:0.0 verticalAccuracy:0.0 timestamp:[NSDate date]];
        _showCount = 1;
        
        [self dropPin:MapTrackingAnnotationTypeActivity title:@"Strated Tracking"];
        
        _locationManager.delegate = self;
//        [_locationManager allowDeferredLocationUpdatesUntilTraveled:100 timeout:60];
        [_locationManager startUpdatingLocation];
        _trackerState = TimeTrackerStateStarted;
        DDLogInfo(@"started tracking location");
    } else {
        DDLogInfo(@"location service is not available, user denied: %d", [[TSSettings sharedInstance] isLocationServiceDenied]);
    }
}

- (void)stopTracking {
    DDLogInfo(@"ending tracking location");
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    [self reset];
    _trackerState = TimeTrackerStateStopped;
    
    [self dropPin:MapTrackingAnnotationTypeActivity title:@"Stopped Tracking"];
}

- (void)scheduleInBackground {
    if (self.trackerState == TimeTrackerStateStopped) {
        return;
    }
    DDLogInfo(@"location service available: %d", [[TSSettings sharedInstance] isLocationServiceAvailable]);
    DDLogInfo(@"APNS available: %d", [[TSSettings sharedInstance] isAPNSAvailable]);
    DDLogInfo(@"background fetch available: %d", [[TSSettings sharedInstance] isBackgroundRefreshAvailable]);
    
    __block UIBackgroundTaskIdentifier enterBackgroundBgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            DDLogInfo(@"background task going to expire");
            [[UIApplication sharedApplication] endBackgroundTask:enterBackgroundBgTaskId];
            enterBackgroundBgTaskId = UIBackgroundTaskInvalid;
            DDLogInfo(@"background task expired");
        });
    }];
    DDLogInfo(@"b4 entering background, bg time remaining: %f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [_timer invalidate];
    [self dropPin:MapTrackingAnnotationTypeActivity title:@"Starting Background Update"];
    
    self.timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(updateInBackground) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)backToForeground {
    if (self.trackerState == TimeTrackerStateStopped) {
        return;
    }
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    [_timer invalidate];
    
    [self dropPin:MapTrackingAnnotationTypeActivity title:@"Stopping Background Update"];
}

- (void)updateInBackground {
    // temporarily disable and enable the GPS chip for a refresh
    _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    _locationManager.distanceFilter = 3000;
    
    [NSThread sleepForTimeInterval:1];
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.distanceFilter = 100;
    
    [self logStuff:@"LS"];
}

- (void)handleBackgroundFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler code:(NSString *)code {
    DDLogInfo(@"background fetch handler fired");
    DDLogInfo(@"b4 bgTask, bg time remaining: %f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
    
    _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            DDLogInfo(@"background task going to expire");
            [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
            _bgTaskId = UIBackgroundTaskInvalid;
            DDLogInfo(@"background task expired");
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logStuff:code];
        
        if (completionHandler) {
            completionHandler(UIBackgroundFetchResultNewData);
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
        _bgTaskId = UIBackgroundTaskInvalid;
    });
}

- (void)logStuff:(NSString *)code {
    NSDate *now = [NSDate date];
    NSTimeInterval bgRemTime = [[UIApplication sharedApplication] backgroundTimeRemaining];
    
    DDLogInfo(@"bg time remaining: %f", bgRemTime);
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    noti.fireDate = now;
    noti.timeZone = [NSTimeZone defaultTimeZone];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd hh:mm:ss"];
    noti.alertBody = [NSString stringWithFormat:@"%@-%@-#%d, %d", code, [formatter stringFromDate:now], (int)_showCount, (int)bgRemTime];
    
    noti.applicationIconBadgeNumber = _showCount;
    noti.soundName = nil;
//    [[UIApplication sharedApplication] scheduleLocalNotification:noti];  // uncomment to show local notification for background location event updates
    
    [self dropPin:MapTrackingAnnotationTypeActivity title:[NSString stringWithFormat:@"Background Event %@", code]];
    _showCount++;
}

- (void)dropPin:(MapTrackingAnnotationType)pinType title:(NSString *)title {
    CLLocation *loc = _lastUpdatedLocation ? _lastUpdatedLocation : _locationManager.location;

    CLLocationDistance remainingDistance = [_destinationLocation distanceFromLocation:loc];
    NSTimeInterval timeRemaining = loc.speed > 0.0 ? (remainingDistance / loc.speed) : [[NSDate distantFuture] timeIntervalSinceReferenceDate];
    
    NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
    MapTrackingAnnotation *anno = [MapTrackingAnnotation newAnnotationWithLocation:loc.coordinate annotationType:pinType serial:_showCount accuracy:loc.horizontalAccuracy remainingDistance:remainingDistance estimatedRemainingTime:timeRemaining inContext:context];
    if (pinType == MapTrackingAnnotationTypeActivity) {
        anno.title = title;
    }
    [_delegateMapView addAnnotation:anno];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.lastUpdatedLocation = [locations lastObject];
    NSDate *updateTime = _lastUpdatedLocation.timestamp;
    NSTimeInterval howRecent = [updateTime timeIntervalSinceNow];
    DDLogInfo(@"updated locations: %@, in %f", locations, howRecent);
    
    [self dropPin:MapTrackingAnnotationTypeUpdate title:nil];
    _showCount++;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DDLogWarn(@"error: %@", error);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    DDLogDebug(@"");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    DDLogDebug(@"");
}

@end
