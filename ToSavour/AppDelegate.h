//
//  AppDelegate.h
//  ToSavour
//
//  Created by Jason Wan on 21/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ECSlidingViewController/ECSlidingViewController.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) ECSlidingViewController *slidingViewController;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic)         NSManagedObjectContext *persistentStoreManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

+ (AppDelegate *)sharedAppDelegate;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationCachesDirectory;
- (NSURL *)addressBookUserImageCacheDirectory;

@end
