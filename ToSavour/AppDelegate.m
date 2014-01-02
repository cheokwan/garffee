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
#import "TSModelIncludes.h"
#import "RestManager.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;

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
    
    // Populate CoreData stuff
#ifdef RESTKIT_GENERATE_SEED_DB
    [self generateSeedDatabase];
#endif
    
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
    
    MUserInfo *currentUserInfo = [MUserInfo currentAppUserInfoInContext:self.managedObjectContext];
    BOOL fbSessionOpened = [FBSession openActiveSessionWithAllowLoginUI:NO];
    DDLogError(@"fb token: %@", [RestManager sharedInstance].facebookToken); // XXX-TEST
    
    if (!currentUserInfo || !fbSessionOpened) {
        // user info does not present, shows the tutorial and login screen
        // and delegate navigation flow to there
        TutorialLoginViewController *tutorialLoginViewController = (TutorialLoginViewController *)[TSTheming viewControllerWithStoryboardIdentifier:NSStringFromClass(TutorialLoginViewController.class)];
        if (currentUserInfo) {
            // user has previously logged in, skip to login page directly
            tutorialLoginViewController.skipTutorial = YES;
        }
        [_slidingViewController.topViewController presentViewController:tutorialLoginViewController animated:NO completion:nil];
    } else {
        // re-fetch user info again for updated app token
        [[RestManager sharedInstance] fetchAppUserInfo:nil];
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
            DDLogError(@"unresolved error saving context: %@ %@", error, error.userInfo);
            abort();
        }
    }
}

#pragma mark - Core Data stack + RestKit

- (void)generateSeedDatabase {
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelInfo);
    RKLogConfigureByName("RestKit/CoreData", RKLogLevelTrace);
    
    NSError *error = nil;
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (!success) {
        DDLogError(@"failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    NSString *seedStorePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"ToSavourSeed.sqlite"];
    RKManagedObjectImporter *importer = [[RKManagedObjectImporter alloc] initWithManagedObjectModel:self.managedObjectModel storePath:seedStorePath];
    [importer importObjectsFromItemAtPath:[[NSBundle mainBundle] pathForResource:@"MProductInfo" ofType:@"json"]
                              withMapping:[MProductInfo defaultEntityMapping]
                                  keyPath:nil
                                    error:&error];
    success = [importer finishImporting:&error];
    if (success) {
        [importer logSeedingInfo];
    } else {
        DDLogError(@"failed to finish import and save seed database due to error: %@", error);
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    // Configure RestKit with CoreData
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelInfo);
    RKLogConfigureByName("RestKit/CoreData", RKLogLevelTrace);
    
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError *error = nil;
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (!success) {
        DDLogError(@"failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"ToSavour.sqlite"];
    NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"ToSavourSeed" ofType:@"sqlite"];
    
    NSPersistentStore __unused *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:seedPath withConfiguration:nil options:nil error:&error];
    if (!persistentStore) {
        DDLogError(@"failed to add persistent store: %@", error);
        _managedObjectContext = nil;
    } else {
        [managedObjectStore createManagedObjectContexts];
        // Configure a managed object cache to ensure we do not create duplicate objects
        managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
        // Set the default store shared instance
        [RKManagedObjectStore setDefaultStore:managedObjectStore];
        _managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ToSavour" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationCachesDirectory {
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:[NSBundle mainBundle].bundleIdentifier];
}

- (NSURL *)addressBookUserImageCacheDirectory {
    NSURL *dirURL = [[self applicationCachesDirectory] URLByAppendingPathComponent:@"AddressBook"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[dirURL path]]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:[dirURL path] withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            DDLogError(@"error creating address book image cache directory: %@", error);
        }
    }
    return dirURL;
}

@end
