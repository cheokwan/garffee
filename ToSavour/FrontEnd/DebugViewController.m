//
//  DebugViewController.m
//  ToSavour
//
//  Created by Jason Wan on 24/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "DebugViewController.h"
#import "TSFrontEndIncludes.h"

@interface DebugViewController ()

@end

@implementation DebugViewController

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
    [self initializeView];
}

- (void)initializeView {
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_DEBUG];
    
    _mapTrackingDebugCell.textLabel.text = @"Map Tracking";
    _mapTrackingDebugCell.detailTextLabel.text = nil;
    _mapTrackingDebugCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _soundwaveTestDebugCell.textLabel.text = @"Soundwave";
    _soundwaveTestDebugCell.detailTextLabel.text = nil;
    _soundwaveTestDebugCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
