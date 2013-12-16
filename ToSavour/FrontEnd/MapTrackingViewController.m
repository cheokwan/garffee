//
//  MapTrackingViewController.m
//  ToSavour
//
//  Created by Jason Wan on 2/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MapTrackingViewController.h"
#import "AppDelegate.h"
#import "TimeTracker.h"
#import "MapTrackingAnnotation.h"
#import "TSFrontEndIncludes.h"


@interface MapTrackingViewController ()
@property (nonatomic, strong)   IBOutlet UISegmentedControl *switcher;
@property (nonatomic, strong)   IBOutlet MKMapView *mapView;
@property (nonatomic, strong)   IBOutlet UITableView *logTable;
@property (nonatomic, strong)   UIBarButtonItem *buttonDropPin;
@property (nonatomic, strong)   UIAlertView *alertViewDropPin;

@property (nonatomic, strong)   MapTrackingAnnotation *destinationAnnotation;
@property (nonatomic, strong)   UIButton *buttonTracking;

@property (nonatomic, strong)   NSFetchedResultsController *fetchedResultsController;
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
    self.navigationItem.titleView = [TSTheming navigationBrandNameTitleView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
    self.managedObjectContext = [AppDelegate sharedAppDelegate].managedObjectContext;
    [TimeTracker sharedInstance].delegateMapView = _mapView;
    _mapView.showsUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    _switcher.selectedSegmentIndex = 0;
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
    UIImage *buttonImage = [TimeTracker sharedInstance].trackerState == TimeTrackerStateStopped ? [UIImage imageNamed:@"PlayIcon"] : [UIImage imageNamed:@"StopIcon"];
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
                    if ([TimeTracker sharedInstance].trackerState == TimeTrackerStateStarted) {
                        [[TimeTracker sharedInstance] stopTracking];
                    }
                    [_mapView removeAnnotation:_destinationAnnotation];
                    [_managedObjectContext deleteObject:_destinationAnnotation];
                }
                self.destinationAnnotation = [MapTrackingAnnotation newAnnotationWithLocation:_mapView.centerCoordinate annotationType:MapTrackingAnnotationTypeDestination inContext:_managedObjectContext];
                [_mapView addAnnotation:_destinationAnnotation];
            }
                break;
            case 2: {   // Clear Everything
                if ([TimeTracker sharedInstance].trackerState == TimeTrackerStateStarted) {
                    [[TimeTracker sharedInstance] stopTracking];
                }
                for (id<MKAnnotation> anno in _mapView.annotations) {
                    if (anno != _mapView.userLocation) {
                        [_mapView removeAnnotation:anno];
                        [_managedObjectContext deleteObject:anno];
                    }
                }
                for (MapTrackingAnnotation *anno in self.fetchedResultsController.fetchedObjects) {
                    [_managedObjectContext deleteObject:anno];
                }
            }
                break;
            case 3: {   // Drop Red Pin
                MapTrackingAnnotation *anno = [MapTrackingAnnotation newAnnotationWithLocation:_mapView.centerCoordinate annotationType:MapTrackingAnnotationTypeUpdate inContext:_managedObjectContext];
                [_mapView addAnnotation:anno];
            }
                break;
            default:
                break;
        }
        NSError *error = nil;
        if (![_managedObjectContext saveToPersistentStore:&error]) {
            DDLogError(@"error saving dropped pins %@", error);
        }
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annoView = nil;
    MapTrackingAnnotation *mtAnnotation = annotation;
    if ([mtAnnotation isKindOfClass:[MapTrackingAnnotation class]]) {
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
        
        if (mtAnnotation.annotationType == MapTrackingAnnotationTypeDestination) {
            pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.draggable = YES;
            pinView.rightCalloutAccessoryView = self.buttonTracking;
        } else if (mtAnnotation.annotationType == MapTrackingAnnotationTypeActivity) {
            pinView.pinColor = MKPinAnnotationColorPurple;
        }
        
        annoView = pinView;
    }
    return annoView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    MapTrackingAnnotation *mtAnnotation = view.annotation;
    if (mtAnnotation.annotationType == MapTrackingAnnotationTypeDestination) {
        if ([TimeTracker sharedInstance].trackerState == TimeTrackerStateStarted) {
            [[TimeTracker sharedInstance] stopTracking];
        } else {
            [[TimeTracker sharedInstance] startTrackingWithDestinationCoordinate:mtAnnotation.coordinate];
        }
        [self buttonTracking];  // update button image
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        MKCoordinateRegion userCenter = MKCoordinateRegionMakeWithDistance(_mapView.userLocation.location.coordinate, 400, 400);
        [_mapView setRegion:userCenter];
    });
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (oldState == MKAnnotationViewDragStateDragging && newState == MKAnnotationViewDragStateEnding) {
        if ([TimeTracker sharedInstance].trackerState == TimeTrackerStateStarted) {
            [[TimeTracker sharedInstance] stopTracking];
        }
    }
    [self buttonTracking];  // udpate button image
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController fetchedObjects].count;
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
        emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, _switcher.frame.origin.y + _switcher.frame.size.height)];
    }
    if (section == 0) {
        return emptyView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MapTrackingAnnotation *annotation = (MapTrackingAnnotation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = annotation.title;
    cell.detailTextLabel.text = annotation.subtitle;
}

#pragma mark - FetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([MapTrackingAnnotation class]) inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize:20];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
        _fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            DDLogError(@"error fetching map annotations: %@", error);
        }
    }
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_logTable beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    DDLogError(@"should not call this");
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_logTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [_logTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[_logTable cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [_logTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_logTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_logTable endUpdates];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:self.view.class]) {
        return YES;
    }
    return NO;
}

@end
