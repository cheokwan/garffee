//
//  TimeTracker.m
//  ToSavour
//
//  Created by Jason Wan on 25/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TimeTracker.h"
#import <CoreLocation/CoreLocation.h>

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
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)updateInBackground {
    NSDate *now = [NSDate date];
    NSTimeInterval bgRemTime = [[UIApplication sharedApplication] backgroundTimeRemaining];
    
    NSLog(@"%s - bg time remaining: %f", __FUNCTION__, [[UIApplication sharedApplication] backgroundTimeRemaining]);
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%s - didUpdateLocations: %@", __FUNCTION__, locations);  // XXX
}

@end
