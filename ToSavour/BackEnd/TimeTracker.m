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
//#import <AFNetworking/AFHTTPRequestOperationManager.h>  // XXX

// combine CoreLocation, BLE iBeacon, UltraSound locationing, Wifi fingerprinting/probing,
// motion activity, user reporting etc in approximating user arrival time

@interface TimeTracker()

@property (nonatomic, strong)   CLLocationManager *locationManager;

// properties that need to be reset between sessions
@property (nonatomic, assign)   NSTimeInterval startTime;
@property (nonatomic, assign)   NSTimeInterval userReportedDuration;
@property (nonatomic, assign)   NSTimeInterval approxRemainingDuration;
@property (nonatomic, assign)   NSTimeInterval lastUpdateTime;

// XXX
@property (nonatomic, strong)   NSTimer *timer;
@property (nonatomic, assign)   NSInteger showCount;
//@property (nonatomic, strong)   AFHTTPRequestOperationManager *reqMan;
//@property (nonatomic, strong)   NSString *urlString;

@property (nonatomic, assign)   __block UIBackgroundTaskIdentifier bgTaskId;
// XXX

@end


@implementation TimeTracker

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
    [self reset];
}

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)reset {
    self.startTime = 0;
    self.userReportedDuration = 0;
    self.approxRemainingDuration = 0;
    self.lastUpdateTime = 0;
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;  // TODO: figure out best accuracy or make it dynamic
    _locationManager.distanceFilter = 100;  // meters, TODO: make it dynamic
    _locationManager.pausesLocationUpdatesAutomatically = NO;  // XXX YES or NO?
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;  // TODO: make it dynamic
}

- (void)startTrackingWithApproxDuration:(NSTimeInterval)duration {
    [self reset];
    
    if ([[TSSettings sharedInstance] isLocationServiceAvailable]) {
        NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
        self.startTime = now;
        self.userReportedDuration = duration;
        self.approxRemainingDuration = duration;
        self.lastUpdateTime = now;
        
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
        DDLogInfo(@"started tracking location");
    } else {
        DDLogInfo(@"location service is not available, user denied: %d", [[TSSettings sharedInstance] isLocationServiceDenied]);
    }
}

- (void)endTracking {
    DDLogInfo(@"ending tracking location");
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    [self reset];
}

- (NSTimeInterval)latestApproxArrivalTime {
    return _startTime + _approxRemainingDuration;
}

- (void)scheduleInBackground {
    DDLogInfo(@"location service available: %d", [[TSSettings sharedInstance] isLocationServiceAvailable]);
    DDLogInfo(@"APNS available: %d", [[TSSettings sharedInstance] isAPNSAvailable]);
    DDLogInfo(@"background fetch available: %d", [[TSSettings sharedInstance] isBackgroundRefreshAvailable]);
    
    [_timer invalidate];
    _showCount = 1;
    
    [self startTrackingWithApproxDuration:600];  // XXXX
    self.timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(updateInBackground) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
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

//- (void)scheduleInBackgroundLongPollAFN {
//    _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//        _bgTaskId = UIBackgroundTaskInvalid;
//    }];
//    
//    _reqMan = nil;
//    _showCount = 1;
//    self.urlString = @"http://192.168.1.126:8888";
//    self.reqMan = [AFHTTPRequestOperationManager manager];
//    
//    void (^successBlock)(AFHTTPRequestOperation *, id);
//    void (^failureBlock)(AFHTTPRequestOperation *, NSError *);
//    
//    successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
//        _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//                _bgTaskId = UIBackgroundTaskInvalid;
//            });
//        }];
//        
//        DDLogInfo(@"request succeeded: %@", responseObject);
//        
//        [self logStuff];
//        
//        [_reqMan GET:_urlString parameters:nil success:successBlock failure:failureBlock];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//            _bgTaskId = UIBackgroundTaskInvalid;
//        });
//    };
//    
//    failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
//        DDLogError(@"request failed: %@", error);
//    };
//    
//    [_reqMan GET:_urlString parameters:nil success:successBlock failure:failureBlock];
//    
//    [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//    _bgTaskId = UIBackgroundTaskInvalid;
//}
//
//- (void)scheduleInBackgroundLongPoll {
//    _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        DDLogInfo(@"background task going to expire");
//        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//        _bgTaskId = UIBackgroundTaskInvalid;
//        DDLogInfo(@"background task expired");
//    }];
//    
//    // set keep alive handler
//    DDLogInfo(@"setting keep alive handler");
//    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
//        // restart stuff, or check the if the chain connection is broken
////        DDLog(@"keep alive handler fired");
////
////        
////        _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
////            DDLog(@"background task going to expire");
////            [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
////            _bgTaskId = UIBackgroundTaskInvalid;
////            DDLog(@"background task expired");
////        }];
////        
////        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:600];
////        req.networkServiceType = NSURLNetworkServiceTypeVoIP;
////        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
////        
////        [NSThread sleepForTimeInterval:3]; // give the last request a little more time to send out
////        
////        DDLog(@"keep alive bg time remaining: %f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
//    }];
//    
//    _showCount = 1;
//    self.urlString = @"http://192.168.1.126:8888";
//    
//    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:600];
//    req.networkServiceType = NSURLNetworkServiceTypeVoIP;
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
//    
//    [NSThread sleepForTimeInterval:3]; // give the last request a little more time to send out
//    
////    [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];  XXXX
////    _bgTaskId = UIBackgroundTaskInvalid;
//}

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

- (void)logStuff:(NSString *)code {  // XXX
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
    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
    
    _showCount++;
}

#pragma mark - NSURLConnectionDelegate, NSURLConnectionDataDelegate

//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    DDLogError(@"error: %@", error);
//    DDLogError(@"terminating chain connections");
//    
//    [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//    _bgTaskId = UIBackgroundTaskInvalid;
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    UIBackgroundTaskIdentifier oldBgTaskId = _bgTaskId;
//    DDLogInfo(@"b4 killing old task, bg time remaining: %f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
//    
//    // start the next bg task
//    _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            DDLogInfo(@"background task going to expire");
//            [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//            _bgTaskId = UIBackgroundTaskInvalid;
//            DDLogInfo(@"background task expired");
//        });
//    }];
//    
//    // end old bg task
//    [[UIApplication sharedApplication] endBackgroundTask:oldBgTaskId];
//    
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//    DDLogInfo(@"response: %@", httpResponse);
//    
//    if (httpResponse.statusCode == 200) {
//        DDLogInfo(@"HTTP status 200 OK");
//        
//        if (_showCount < 30) {
//            [self logStuff];
//            // send out request again
//            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:600];
//            req.networkServiceType = NSURLNetworkServiceTypeVoIP;
//            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
//        } else {
//            DDLogWarn(@"too much responses, end logging stuff");
//        }
//    } else {
//        DDLogError(@"HTTP failed with status %d", (int)httpResponse.statusCode);
//        DDLogError(@"terminating chain connections");
//        
//        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//        _bgTaskId = UIBackgroundTaskInvalid;
//    }
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//        _bgTaskId = UIBackgroundTaskInvalid;
//    });
//}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    DDLogInfo(@"didUpdateLocations: %@", locations);  // XXX
    
    CLLocation *loc = [locations lastObject];
    NSDate *updateTime = loc.timestamp;
    NSTimeInterval howRecent = [updateTime timeIntervalSinceNow];
    DDLogInfo(@"location updated in: %f", howRecent);
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
