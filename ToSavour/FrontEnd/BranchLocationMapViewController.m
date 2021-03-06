//
//  BranchLocationMapViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 13/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "BranchLocationMapViewController.h"

#import <UIView+Helpers/UIView+Helpers.h>
#import "TSLocalizedString.h"
#import "TSTheming.h"

#define REGION_SPAN_DELTA       1000.0f

@interface BranchLocationMapViewController ()

@end

@implementation BranchLocationMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_LOCATION];
    
    self.mapView.delegate = self;
    MapAnnotation *annotation = [[MapAnnotation alloc] initWithBranch:_branch];
    [_mapView addAnnotation:annotation];
    _mapView.centerCoordinate = annotation.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_mapView.centerCoordinate, REGION_SPAN_DELTA, REGION_SPAN_DELTA);
    _mapView.region = region;
    _mapView.mapType = MKMapTypeStandard;
    [_mapView selectAnnotation:annotation animated:YES];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annoView = nil;
    MapAnnotation *mtAnnotation = annotation;
    if ([mtAnnotation isKindOfClass:[MapAnnotation class]]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MapAnnotation"];
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapAnnotation"];
        }
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_app_logo"]];
        logoImageView.frame = CGRectMake(0, 0, pinView.frameSizeHeight - 5, pinView.frameSizeHeight - 5);
        logoImageView.layer.cornerRadius = 5.0f;
        logoImageView.layer.masksToBounds = YES;
        pinView.leftCalloutAccessoryView = logoImageView;
        pinView.draggable = NO;
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        
        annoView = pinView;
    }
    return annoView;
}

@end


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
        return LS_DISTANCE_UNAVAILABLE;
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
