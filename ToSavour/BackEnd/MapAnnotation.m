//
//  MapAnnotation.m
//  ToSavour
//
//  Created by LAU Leung Yan on 13/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

- (id)initWithBranch:(MBranch *)branch {
    self = [self init];
    if (self) {
        self.branch = branch;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([_branch.latitude doubleValue], [_branch.longitude doubleValue]);
}

- (NSString *)title {
    return _branch.name;
}

- (NSString *)subtitle {
    CLLocationDistance distance = self.distance;
    if (distance == CLLocationDistanceMax || distance < 0.0) {
        return LS_LOCATION_UNAVAILABLE;
    } else {
        return [NSString stringWithFormat:@"%f m", distance];
    }
}

- (CLLocationDistance)distance {
    CLLocation *userLocation = _mapView.userLocation.location;
    CLLocation *branchLocation = [[CLLocation alloc] initWithLatitude:[_branch.latitude doubleValue] longitude:[_branch.longitude doubleValue]];
    CLLocationDistance distance = [branchLocation distanceFromLocation:userLocation];
    return distance;
}

@end
