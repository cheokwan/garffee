//
//  TimeTracker.m
//  ToSavour
//
//  Created by Jason Wan on 25/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TimeTracker.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>  // XXX

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
@property (nonatomic, strong)   AFHTTPRequestOperationManager *reqMan;
@property (nonatomic, strong)   NSString *urlString;

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
    _locationManager.distanceFilter = 200; // meters, TODO: make it dynamic
}

- (void)startTrackingWithApproxDuration:(NSTimeInterval)duration {
    [self reset];
    NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
    self.startTime = now;
    self.userReportedDuration = duration;
    self.approxRemainingDuration = duration;
    self.lastUpdateTime = now;
    
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
}

- (void)endTracking {
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    [self reset];
}

- (NSTimeInterval)latestApproxArrivalTime {
    return _startTime + _approxRemainingDuration;
}

- (void)scheduleInBackground {
    [_timer invalidate];
    _showCount = 1;
    self.timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(updateInBackground) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)scheduleInBackgroundLongPollAFN {
    _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
        _bgTaskId = UIBackgroundTaskInvalid;
    }];
    
    _reqMan = nil;
    _showCount = 1;
    self.urlString = @"http://192.168.1.126:8888";
    self.reqMan = [AFHTTPRequestOperationManager manager];
    
    void (^successBlock)(AFHTTPRequestOperation *, id);
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *);
    
    successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
                _bgTaskId = UIBackgroundTaskInvalid;
            });
        }];
        
        NSLog(@"%s - request succeeded: %@", __FUNCTION__, responseObject);
        
        [self logStuff];
        
        [_reqMan GET:_urlString parameters:nil success:successBlock failure:failureBlock];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
            _bgTaskId = UIBackgroundTaskInvalid;
        });
    };
    
    failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s - request failed: %@", __FUNCTION__, error);
    };
    
    [_reqMan GET:_urlString parameters:nil success:successBlock failure:failureBlock];
    
    [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
    _bgTaskId = UIBackgroundTaskInvalid;
}

- (void)scheduleInBackgroundLongPoll {
    _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"%s - background task going to expire", __FUNCTION__);
        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
        _bgTaskId = UIBackgroundTaskInvalid;
        NSLog(@"%s - background task expired", __FUNCTION__);
    }];
    
    // set keep alive handler
    NSLog(@"%s - setting keep alive handler", __FUNCTION__);
    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        // restart stuff, or check the if the chain connection is broken
//        NSLog(@"%s - keep alive handler fired", __FUNCTION__);
//
//        
//        _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//            NSLog(@"%s - background task going to expire", __FUNCTION__);
//            [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//            _bgTaskId = UIBackgroundTaskInvalid;
//            NSLog(@"%s - background task expired", __FUNCTION__);
//        }];
//        
//        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:600];
//        req.networkServiceType = NSURLNetworkServiceTypeVoIP;
//        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
//        
//        [NSThread sleepForTimeInterval:3]; // give the last request a little more time to send out
//        
//        NSLog(@"%s - keep alive bg time remaining: %f", __FUNCTION__, [[UIApplication sharedApplication] backgroundTimeRemaining]);
    }];
    
    _showCount = 1;
    self.urlString = @"http://192.168.1.126:8888";
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:600];
    req.networkServiceType = NSURLNetworkServiceTypeVoIP;
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    [NSThread sleepForTimeInterval:3]; // give the last request a little more time to send out
    
//    [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];  XXXX
//    _bgTaskId = UIBackgroundTaskInvalid;
}

- (void)updateInBackground {
    [self endTracking];
    [self startTrackingWithApproxDuration:600];
    
    [self logStuff];
}

- (void)logStuff {  // XXX
    NSDate *now = [NSDate date];
    NSTimeInterval bgRemTime = [[UIApplication sharedApplication] backgroundTimeRemaining];
    
    NSLog(@"%s - bg time remaining: %f", __FUNCTION__, bgRemTime);
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    noti.fireDate = now;
    noti.timeZone = [NSTimeZone defaultTimeZone];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd hh:mm:ss"];
    noti.alertBody = [NSString stringWithFormat:@"%@-#%d, %d", [formatter stringFromDate:now], (int)_showCount, (int)bgRemTime];
    
    noti.applicationIconBadgeNumber = _showCount;
    noti.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
    _showCount++;
}

#pragma mark - NSURLConnectionDelegate, NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%s - error: %@", __FUNCTION__, error);
    NSLog(@"%s - terminating chain connections", __FUNCTION__);
    
    [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
    _bgTaskId = UIBackgroundTaskInvalid;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    UIBackgroundTaskIdentifier oldBgTaskId = _bgTaskId;
    NSLog(@"%s - b4 killing old task, bg time remaining: %f", __FUNCTION__, [[UIApplication sharedApplication] backgroundTimeRemaining]);
    
    // start the next bg task
    _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%s - background task going to expire", __FUNCTION__);
            [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
            _bgTaskId = UIBackgroundTaskInvalid;
            NSLog(@"%s - background task expired", __FUNCTION__);
        });
    }];
    
    // end old bg task
    [[UIApplication sharedApplication] endBackgroundTask:oldBgTaskId];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"%s - response: %@", __FUNCTION__, httpResponse);
    
    if (httpResponse.statusCode == 200) {
        NSLog(@"%s - HTTP status 200 OK", __FUNCTION__);
        
        if (_showCount < 30) {
            [self logStuff];
            // send out request again
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:600];
            req.networkServiceType = NSURLNetworkServiceTypeVoIP;
            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
        } else {
            NSLog(@"%s - too much responses, end logging stuff", __FUNCTION__);
        }
    } else {
        NSLog(@"%s - HTTP failed with status %d", __FUNCTION__, (int)httpResponse.statusCode);
        NSLog(@"%s - terminating chain connections", __FUNCTION__);
        
        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
        _bgTaskId = UIBackgroundTaskInvalid;
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
//        _bgTaskId = UIBackgroundTaskInvalid;
//    });
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%s - didUpdateLocations: %@", __FUNCTION__, locations);  // XXX
}

@end
