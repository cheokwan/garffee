//
//  BluetoothBeaconTestViewController.m
//  ToSavour
//
//  Created by Jason Wan on 7/3/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "BluetoothBeaconTestViewController.h"
#import "TSTheming.h"

@interface BluetoothBeaconTestViewController ()

@end

@implementation BluetoothBeaconTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.uuid = [[NSUUID alloc] initWithUUIDString:@"84A63B67-D74C-45E2-ADB4-303974FE0B63"];
    self.regionIdentifier = [[NSBundle mainBundle].bundleIdentifier stringByAppendingString:@".iBeaconRegionIdentifier"];
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:@"Bluetooth Beacon"];
    [_broadcastButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.broadcastBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid major:1 minor:1 identifier:_regionIdentifier];
    self.monitorBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid major:1 minor:1 identifier:_regionIdentifier];
    self.uuidLabel.text = _broadcastBeaconRegion.proximityUUID.UUIDString;
    
    self.beaconPeripheralData = [_broadcastBeaconRegion peripheralDataWithMeasuredPower:nil];  // default power
//    if ([CBPeripheralManager authorizationStatus] == CBPeripheralManagerAuthorizationStatusAuthorized) {
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
//    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startMonitoringForRegion:_monitorBeaconRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_peripheralManager stopAdvertising];
    [_locationManager stopRangingBeaconsInRegion:_monitorBeaconRegion];
    _peripheralManager.delegate = nil;
    _locationManager.delegate = nil;
}

- (void)buttonPressed:(id)sender {
    if (sender == _broadcastButton) {
        [_peripheralManager startAdvertising:_beaconPeripheralData];
    }
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral != _peripheralManager) {
        return;
    }
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn: {
            DDLogInfo(@"CBPeripheralManagerStatePoweredOn");
//            [_peripheralManager startAdvertising:_beaconPeripheralData];
        }
            break;
        case CBPeripheralManagerStatePoweredOff: {
            DDLogInfo(@"CBPeripheralManagerStatePoweredOff");
            [_peripheralManager stopAdvertising];
        }
            break;
        case CBPeripheralManagerStateResetting: {
            DDLogInfo(@"CBPeripheralManagerStateResetting");
        }
            break;
        case CBPeripheralManagerStateUnauthorized: {
            DDLogInfo(@"CBPeripheralManagerStateUnauthorized");
        }
            break;
        case CBPeripheralManagerStateUnsupported: {
            DDLogInfo(@"CBPeripheralManagerStateUnsupported");
        }
            break;
        case CBPeripheralManagerStateUnknown: {
            DDLogInfo(@"CBPeripheralManagerStateUnknown");
        }
            break;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    DDLogInfo(@"did enter region: %@", region);
    [_locationManager startRangingBeaconsInRegion:_monitorBeaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    DDLogInfo(@"did exit region: %@", region);
    [_locationManager stopRangingBeaconsInRegion:_monitorBeaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    DDLogInfo(@"did range beacons: %@ in region: %@", beacons, region);
    
    CLBeacon *beacon = [beacons lastObject];
    switch (beacon.proximity) {
        case CLProximityFar: {
            DDLogInfo(@"CLProximityFar");
            _statusLabel.text = @"Cold";
            [self.view setBackgroundColor:[UIColor blueColor]];
        }
            break;
        case CLProximityNear: {
            DDLogInfo(@"CLProximityNear");
            _statusLabel.text = @"Warmer";
            [self.view setBackgroundColor:[UIColor orangeColor]];
        }
            break;
        case CLProximityImmediate: {
            DDLogInfo(@"CLProximityImmediate");
            _statusLabel.text = @"Disco";
            [self.view setBackgroundColor:[UIColor redColor]];
        }
            break;
        case CLProximityUnknown: {
            DDLogInfo(@"CLProximityUnknown");
            _statusLabel.text = @"Pitch Black";
            [self.view setBackgroundColor:[UIColor blackColor]];
        }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [_locationManager startRangingBeaconsInRegion:_monitorBeaconRegion];
}

@end
