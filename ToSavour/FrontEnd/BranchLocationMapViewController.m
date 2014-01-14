//
//  BranchLocationMapViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 13/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "BranchLocationMapViewController.h"

#import <UIView+Helpers/UIView+Helpers.h>
#import "MapAnnotation.h"
#import "TSLocalizedString.h"
#import "TSTheming.h"

#define REGION_SPAN_DELTA       500.0f

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
    _mapView.mapType = MKMapTypeHybrid;
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
