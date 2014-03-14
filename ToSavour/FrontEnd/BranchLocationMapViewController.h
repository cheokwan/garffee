//
//  BranchLocationMapViewController.h
//  ToSavour
//
//  Created by LAU Leung Yan on 13/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import "MBranch.h"

@interface BranchLocationMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MBranch *branch;

@end


@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) MBranch *branch;
@property (nonatomic, strong) MKMapView *mapView;

- (id)initWithBranch:(MBranch *)branch;

@end