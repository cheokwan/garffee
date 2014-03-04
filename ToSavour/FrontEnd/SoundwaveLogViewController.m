//
//  SoundwaveLogViewController.m
//  ToSavour
//
//  Created by Jason Wan on 4/3/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "SoundwaveLogViewController.h"
#import "TSFrontEndIncludes.h"
#import "MFrequencyInfo.h"

@interface SoundwaveLogViewController ()
@property (nonatomic, strong)   UIBarButtonItem *dismissButton;
@property (nonatomic, strong)   UIBarButtonItem *trashButton;
@property (nonatomic, strong)   NSFetchedResultsController *fetchedResultsController;
@end

@implementation SoundwaveLogViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeView {
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:@"Soundwave Log"];
    self.navigationItem.rightBarButtonItem = self.dismissButton;
    self.navigationItem.leftBarButtonItem = self.trashButton;
}

- (UIBarButtonItem *)dismissButton {
    if (!_dismissButton) {
        self.dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(buttonPressed:)];
        _dismissButton.tintColor = [TSTheming defaultAccentColor];
    }
    return _dismissButton;
}

- (UIBarButtonItem *)trashButton {
    if (!_trashButton) {
        self.trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(buttonPressed:)];
        _trashButton.tintColor = [TSTheming defaultAccentColor];
    }
    return _trashButton;
}

- (void)buttonPressed:(id)sender {
    if (sender == _dismissButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (sender == _trashButton) {
        [MFrequencyInfo removeALlObjectsInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
        [[AppDelegate sharedAppDelegate].managedObjectContext saveToPersistentStore];
    }
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [MFrequencyInfo fetchRequest];
        NSSortDescriptor *sdTimestamp = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        fetchRequest.sortDescriptors = @[sdTimestamp];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[AppDelegate sharedAppDelegate].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            DDLogError(@"error fetching soundwave frequency log info: %@", error);
        }
    }
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MFrequencyInfo *freqInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"<%.1f, %.1f> Hz - mag: %.4f", [freqInfo.frequencyBinLow floatValue], [freqInfo.frequencyBinHigh floatValue], [freqInfo.normalizedMagnitude floatValue]];
    cell.detailTextLabel.text = [freqInfo.timestamp defaultStringRepresentation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SoundwaveLogCell" forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
