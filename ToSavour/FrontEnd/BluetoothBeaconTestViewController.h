//
//  BluetoothBeaconTestViewController.h
//  ToSavour
//
//  Created by Jason Wan on 7/3/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothBeaconTestViewController : UIViewController<CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong)   IBOutlet UILabel *uuidLabel;
@property (nonatomic, strong)   IBOutlet UILabel *statusLabel;
@property (nonatomic, strong)   IBOutlet UIButton *broadcastButton;

@property (nonatomic, strong)   NSUUID *uuid;
@property (nonatomic, strong)   NSString *regionIdentifier;


@property (nonatomic, strong)   CLBeaconRegion *broadcastBeaconRegion;
@property (nonatomic, strong)   CLBeaconRegion *monitorBeaconRegion;
@property (nonatomic, strong)   CLLocationManager *locationManager;
@property (nonatomic, strong)   NSDictionary *beaconPeripheralData;
@property (nonatomic, strong)   CBPeripheralManager *peripheralManager;

@end
