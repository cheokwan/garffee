//
//  MapTrackingViewController.m
//  ToSavour
//
//  Created by Jason Wan on 2/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MapTrackingViewController.h"
#import "TimeTracker.h"

@interface MapTrackingAnnotation : NSObject<MKAnnotation>
@end

@implementation MapTrackingAnnotation
@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        self.coordinate = coord;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

- (NSString *)title {
    return @"Tracked Position";
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"altitude: %f, longtitude %f", _coordinate.latitude, _coordinate.longitude];
}
@end


@interface MapDestinationAnnotation : MapTrackingAnnotation
@end

@implementation MapDestinationAnnotation
- (NSString *)title {
    return @"Final Destination";
}
@end



@interface MapTrackingViewController ()
@property (nonatomic, strong)   IBOutlet UISegmentedControl *switcher;
@property (nonatomic, strong)   IBOutlet MKMapView *mapView;
@property (nonatomic, strong)   IBOutlet UITableView *logTable;
@property (nonatomic, strong)   UIBarButtonItem *buttonDropPin;
@property (nonatomic, strong)   UIAlertView *alertViewDropPin;

@property (nonatomic, strong)   MapDestinationAnnotation *destinationAnnotation;
@property (nonatomic, strong)   UIButton *buttonTracking;
@end

@implementation MapTrackingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initializeView {
    _mapView.mapType = MKMapTypeStandard;
    _mapView.delegate = self;
    _logTable.dataSource = self;
    _logTable.delegate = self;
    _logTable.allowsSelection = NO;
    [_switcher addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    self.buttonDropPin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonPressed:)];
    self.navigationItem.rightBarButtonItem = _buttonDropPin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
    [TimeTracker sharedInstance].delegateMapView = _mapView;
    _mapView.showsUserLocation = YES;
    
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        MKCoordinateRegion userCenter = MKCoordinateRegionMakeWithDistance(_mapView.userLocation.location.coordinate, 400, 400);
        [_mapView setRegion:userCenter];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [self.view bringSubviewToFront:_logTable];
    [self.view bringSubviewToFront:_mapView];
    [self.view bringSubviewToFront:_switcher];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)swapMapAndLog {
    [self.view exchangeSubviewAtIndex:[self.view.subviews indexOfObject:_mapView] withSubviewAtIndex:[self.view.subviews indexOfObject:_logTable]];
}

- (void)valueChanged:(id)sender {
    if (sender == _switcher) {
        switch (_switcher.selectedSegmentIndex) {
            case 0: { // Map
                [UIView animateWithDuration:0.5 animations:^{
                    [self swapMapAndLog];
                }];
                break;
            }
            case 1: { // Log
                [UIView animateWithDuration:0.5 animations:^{
                    [self swapMapAndLog];
                }];
                break;
            }
            default:
                break;
        }
    }
}

- (void)buttonPressed:(id)sender {
    if (sender == _buttonDropPin) {
        if (!_alertViewDropPin) {
            self.alertViewDropPin = [[UIAlertView alloc] initWithTitle:nil message:@"What do you want?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Drop Destination", @"Clear Everything", @"Drop Red Pin", nil];
        }
        [_alertViewDropPin show];
    }
}

- (UIButton *)buttonTracking {
    if (!_buttonTracking) {
        self.buttonTracking = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonTracking.frame = CGRectMake(0, 0, 26, 26);
    }
    UIImage *buttonImage = [TimeTracker sharedInstance].trackingStarted ? [UIImage imageNamed:@"StopIcon"] : [UIImage imageNamed:@"PlayIcon"];
    [_buttonTracking setImage:buttonImage forState:UIControlStateNormal];
    return _buttonTracking;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _alertViewDropPin) {
        switch (buttonIndex) {
            case 0: {   // Cancel
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            }
                break;
            case 1: {   // Drop Destination
                if (_destinationAnnotation) {
                    [_mapView removeAnnotation:_destinationAnnotation];
                }
                self.destinationAnnotation = [[MapDestinationAnnotation alloc] initWithLocation:_mapView.centerCoordinate];
                [_mapView addAnnotation:_destinationAnnotation];
            }
                break;
            case 2: {   // Clear Everything
                for (id<MKAnnotation> anno in _mapView.annotations) {
                    if (anno != _mapView.userLocation) {
                        [_mapView removeAnnotation:anno];
                    }
                }
            }
                break;
            case 3: {   // Drop Red Pin
                MapTrackingAnnotation *anno = [[MapTrackingAnnotation alloc] initWithLocation:_mapView.centerCoordinate];
                [_mapView addAnnotation:anno];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annoView = nil;
    if ([annotation isKindOfClass:[MapTrackingAnnotation class]]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MapTrackingAnnotation"];
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapTrackingAnnotation"];
        }
        pinView.rightCalloutAccessoryView = nil;
        pinView.leftCalloutAccessoryView = nil;
        pinView.draggable = NO;
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        
        annoView = pinView;
    }
    // indented fall through
    if ([annotation isKindOfClass:[MapDestinationAnnotation class]]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)annoView;
        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.draggable = YES;
        
        pinView.rightCalloutAccessoryView = self.buttonTracking;
    }
    return annoView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([view.annotation isKindOfClass:[MapDestinationAnnotation class]]) {
        if ([TimeTracker sharedInstance].trackingStarted) {
            [[TimeTracker sharedInstance] stopTracking];
        } else {
            [[TimeTracker sharedInstance] startTrackingWithApproxDuration:0];
        }
        [self buttonTracking];  // update the button image just in case
    }
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [self tableView:tableView viewForHeaderInSection:section].frame.size.height;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static UIView *emptyView = nil;
    if (!emptyView) {
        emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, _switcher.frame.origin.y - self.navigationController.navigationBar.frame.origin.y)];
        emptyView.backgroundColor = [UIColor yellowColor];
    }
    if (section == 0) {
        return emptyView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
    }
    
    return cell;
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    if (bar == self.navigationController.navigationBar) {
        return UIBarPositionTopAttached;
    }
    return UIBarPositionAny;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


@end
