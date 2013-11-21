//
//  MasterViewController.h
//  ToSavour
//
//  Created by Jason Wan on 21/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
// XXX
#import <ChatHeads/CHDraggingCoordinator.h>
// XXX

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, /* XXX */CHDraggingCoordinatorDelegate/* XXX */>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
