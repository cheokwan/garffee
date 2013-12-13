//
//  AppDelegate.m
//  ToSavour
//
//  Created by Jason Wan on 21/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TSLogFormatter.h"
#import "TSSettings.h"
#import "TSFrontEndIncludes.h"
#import "TimeTracker.h"
#import "MainTabBarController.h"
#import "SlideMenuViewController.h"
#import "TutorialLoginViewController.h"
#import "MUserInfo.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (AppDelegate *)sharedAppDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Configure CocoaLumberjack logging framework
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    fileLogger.logFormatter = [[TSLogFormatter alloc] init];
    [DDASLLogger sharedInstance].logFormatter = [[TSLogFormatter alloc] init];
    [DDTTYLogger sharedInstance].logFormatter = [[TSLogFormatter alloc] init];
    [DDTTYLogger sharedInstance].colorsEnabled = YES;
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:LOG_FLAG_INFO];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor purpleColor] backgroundColor:nil forFlag:LOG_FLAG_DEBUG];
    [DDLog addLogger:fileLogger];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDLogDebug(@"");
    
    // Configure Fetch background mode
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Configure APNS
    UIRemoteNotificationType notiTypes = UIRemoteNotificationTypeNewsstandContentAvailability|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge;
    [application registerForRemoteNotificationTypes:notiTypes];
    
    // Populate views
    self.slidingViewController = (ECSlidingViewController *)self.window.rootViewController;
    _slidingViewController.topViewController = [TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(MainTabBarController.class)];
    _slidingViewController.underRightViewController = [TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(SlideMenuViewController.class)];
    _slidingViewController.anchorRightPeekAmount  = 100.0;
    _slidingViewController.anchorLeftRevealAmount = 250.0;  // XXX-FIX set correct amount
    [self.window makeKeyAndVisible];
    
    MUserInfo *currentUserInfo = [MUserInfo currentUserInfoInContext:self.managedObjectContext];
    if (!currentUserInfo || ![[FBSession activeSession] isOpen]) {  // TODO: or facebook is not logged in
        // user info does not present, shows the tutorial and login screen
        // and delegate navigation flow to there
        TutorialLoginViewController *tutorialViewController = (TutorialLoginViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(TutorialLoginViewController.class)];
        [_slidingViewController.topViewController presentViewController:tutorialViewController animated:NO completion:nil];
    }
    
    return YES;
}

#pragma mark - Background Fetch and APNS

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    DDLogDebug(@"");
    [[TimeTracker sharedInstance] handleBackgroundFetchWithCompletionHandler:completionHandler code:@"BF"];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DDLogInfo(@"got APNS token: %@", deviceToken);
    [TSSettings sharedInstance].apnsToken = deviceToken;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogWarn(@"failed to register APNS token: %@", error);
    [TSSettings sharedInstance].apnsToken = nil;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DDLogDebug(@"");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    DDLogDebug(@"");
    [[TimeTracker sharedInstance] handleBackgroundFetchWithCompletionHandler:completionHandler code:@"RN"];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    DDLogDebug(@"");
}

#pragma mark -

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL handled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    DDLogInfo(@"facebook login handled: %@", @(handled));  // XXX-TEST
    return handled;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DDLogDebug(@"");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogDebug(@"");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    DDLogInfo(@"entering background");
    
    [[TimeTracker sharedInstance] scheduleInBackground];  // XXX-FIX schedule location timer in bg
    
    DDLogInfo(@"entered background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogDebug(@"");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[TimeTracker sharedInstance] backToForeground];  // XXX-FIX
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DDLogDebug(@"");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogDebug(@"");
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (void)generateSeedDatabase {
    // XXX-FIX TODO:
//    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
//    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
//    NSError *error = nil;
//    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
//    if (!success) {
//        DDLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
//        return;
//    }
//    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"ToSavourSeed.sqlite"];
//    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
//    if (!persistentStore) {
//        DDLogError(@"Failed adding persistent store at path '%@': %@", path, error);
//        return;
//    }
//    [managedObjectStore createManagedObjectContexts];
//    
//    RKEntityMapping *articleMapping = [RKEntityMapping mappingForEntityForName:@"Article" inManagedObjectStore:managedObjectStore];
//    [articleMapping addAttributeMappingsFromArray:@[@"title", @"author", @"body"]];
//    
//    RKEntityMapping *branchMapping = [RKEntityMapping mappingForEntityForName:@"MBranch" inManagedObjectStore:managedObjectStore];
//    [branchMapping addAttributeMappingsFromDictionary:@{@"id": @"",
//                                                        @"name": @""}];
//    
//    NSString *seedPath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"MySeedDatabase.sqlite"];
//    RKManagedObjectImporter *importer = [[RKManagedObjectImporter alloc] initWithManagedObjectModel:managedObjectStore.managedObjectModel storePath:seedPath];
//    
//    // Import the files "articles.json" from the Main Bundle using our RKEntityMapping
//    // JSON looks like {"articles": [ {"title": "Article 1", "body": "Text", "author": "Blake" ]}
//    NSError *error;
//    NSBundle *mainBundle = [NSBundle mainBundle];
//    [importer importObjectsFromItemAtPath:[mainBundle pathForResource:@"articles" ofType:@"json"]
//                              withMapping:articleMapping
//                                  keyPath:@"articles"
//                                    error:&error];
//    
//    BOOL success = [importer finishImporting:&error];
//    if (success) {
//        [importer logSeedingInfo];
//    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    // Configure RestKit with CoreData
    NSError *error = nil;
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];
    // Initialize the Core Data stack
    [managedObjectStore createPersistentStoreCoordinator];
//    NSPersistentStore __unused *persistentStore = [managedObjectStore addInMemoryPersistentStore:&error];  XXX-TEMP
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"ToSavour.sqlite"];
    NSPersistentStore __unused *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (!persistentStore) {
        DDLogError(@"Failed to add persistent store: %@", error);
        _managedObjectContext = nil;
    } else {
        [managedObjectStore createManagedObjectContexts];
        // Set the default store shared instance
        [RKManagedObjectStore setDefaultStore:managedObjectStore];
        _managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
    }
    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ToSavour" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ToSavour.sqlite"];
//    
//    NSError *error = nil;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        /*
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//         
//         Typical reasons for an error here include:
//         * The persistent store is not accessible;
//         * The schema for the persistent store is incompatible with current managed object model.
//         Check the error message to determine what the actual problem was.
//         
//         
//         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
//         
//         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
//         * Simply deleting the existing store:
//         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
//         
//         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
//         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
//         
//         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
//         
//         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
