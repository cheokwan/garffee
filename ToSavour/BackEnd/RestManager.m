//
//  RestManager.m
//  ToSavour
//
//  Created by Jason Wan on 19/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "RestManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AFNetworking/AFNetworking.h>
#import "TSModelIncludes.h"

@interface RestManager()
@property (nonatomic, strong)   RKObjectManager *facebookObjectManager;
@property (nonatomic, strong)   RKObjectManager *appObjectManager;
@end

@implementation RestManager
static const NSString *facebookAPIBaseURLString = @"https://graph.facebook.com";
static const NSString *appAPIBaseURLString = @"http://f34e2b0b303842659d3e58ed6dc844a5.cloudapp.net:8080/RESTfulWCFUsersServiceEndPoint.svc";

@synthesize appToken = _appToken;
@synthesize defaultDotNetValueTransformer = _defaultDotNetValueTransformer;
@synthesize defaultDotNetDateFormatter = _defaultDotNetDateFormatter;

#pragma mark - Internal

+ (RestManager *)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static RestManager *instance = nil;
    dispatch_once(&token, ^{
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);  // XXX-TEST
        instance = [[RestManager alloc] init];
    });
    return instance;
}

- (RKObjectManager *)facebookObjectManager {
    if (!_facebookObjectManager) {
        self.facebookObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:(NSString *)facebookAPIBaseURLString]];
//        [_facebookObjectManager addResponseDescriptorsFromArray:@[[MUserInfo defaultResponseDescriptor], [MFriendInfo defaultResponseDescriptor]]];
//        _facebookObjectManager.operationQueue = [NSOperationQueue currentQueue];
    }
    return _facebookObjectManager;
}

- (RKObjectManager *)appObjectManager {
    if (!_appObjectManager) {
        self.appObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:(NSString *)appAPIBaseURLString]];
    }
    return _appObjectManager;
}

- (NSString *)facebookToken {
    return [[[FBSession activeSession] accessTokenData] accessToken];
}

- (void)setAppToken:(NSString *)appToken {
    if (appToken) {
        // TODO: persist to key chain
        _appToken = appToken;
    }
}

- (NSString *)appToken {
    return _appToken;
}

- (RKCompoundValueTransformer *)defaultDotNetValueTransformer {
    if (!_defaultDotNetValueTransformer) {
        _defaultDotNetValueTransformer = [[RKCompoundValueTransformer alloc] init];
        [_defaultDotNetValueTransformer addValueTransformer:self.defaultDotNetDateFormatter];
        for (RKValueTransformer *vt in [RKValueTransformer defaultValueTransformer]) {
            [_defaultDotNetValueTransformer addValueTransformer:vt];
        }
    }
    return _defaultDotNetValueTransformer;
}

- (RKDotNetDateFormatter *)defaultDotNetDateFormatter {
    if (!_defaultDotNetDateFormatter) {
        _defaultDotNetDateFormatter = [RKDotNetDateFormatter dotNetDateFormatterWithTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    return _defaultDotNetDateFormatter;
}


#pragma mark - Services

// TODO: support fetching outside of non-mainqueue contexts

- (void)fetchFacebookAppUserInfo:(__weak id<RestManagerResponseHandler>)handler {
    // fetch user info
    NSString *servicePath = [NSString stringWithFormat:@"/me/?access_token=%@&fields=id,name,username,email,first_name,middle_name,last_name,gender,age_range,link,locale,birthday,picture.width(120),picture.height(120)", self.facebookToken];
    NSURL *serviceURL = [NSURL URLWithString:[facebookAPIBaseURLString stringByAppendingPathComponent:servicePath]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[[MUserInfo facebookResponseDescriptor]]];
    
    operation.managedObjectContext = [AppDelegate sharedAppDelegate].managedObjectContext;
    operation.managedObjectCache = [RKManagedObjectStore defaultStore].managedObjectCache;
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            [handler restManagerService:_cmd succeededWithOperation:operation userInfo:@{@"mappingResult": mappingResult}];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DDLogWarn(@"REST operation failed: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    [self.facebookObjectManager enqueueObjectRequestOperation:operation];
}


- (void)fetchFacebookFriendsInfo:(__weak id<RestManagerResponseHandler>)handler {
    // fetch friends info
    NSString *servicePath = [NSString stringWithFormat:@"/me/friends?access_token=%@&fields=id,name,username,email,first_name,middle_name,last_name,gender,age_range,link,locale,birthday,picture.width(120),picture.height(120)", self.facebookToken];
    NSURL *serviceURL = [NSURL URLWithString:[facebookAPIBaseURLString stringByAppendingPathComponent:servicePath]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[[MFriendInfo facebookResponseDescriptor]]];
    
    operation.managedObjectContext = [AppDelegate sharedAppDelegate].managedObjectContext;
    operation.managedObjectCache = [RKManagedObjectStore defaultStore].managedObjectCache;
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            [handler restManagerService:_cmd succeededWithOperation:operation userInfo:@{@"mappingResult": mappingResult}];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DDLogWarn(@"REST operation failed: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    [self.facebookObjectManager enqueueObjectRequestOperation:operation];
}

- (void)fetchAppUserInfo:(__weak id<RestManagerResponseHandler>)handler {
    NSURL *serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingString:@"/users"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    MUserInfo *appUser = [MUserInfo currentUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    [request setValue:self.facebookToken forHTTPHeaderField:@"Authorization"];
    [request setValue:appUser.fbID forHTTPHeaderField:@"FacebookId"];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // responseObject is JSON
        BOOL emptyResponse = [responseObject performSelector:@selector(count)] == 0;  // JSON is either array or dict
        if (emptyResponse) {
            // user does not exist on server side, convert the facebook user to create a new one
            DDLogInfo(@"fetch app user info returns empty response, going to create a new app user");
            
            RKRequestDescriptor *serialization = [RKRequestDescriptor requestDescriptorWithMapping:[MUserInfo appUserCreationEntityMapping] objectClass:MUserInfo.class rootKeyPath:nil method:RKRequestMethodPOST];
            NSError *error = nil;
            NSMutableDictionary *jsonDict = [[RKObjectParameterization parametersWithObject:appUser requestDescriptor:serialization error:&error] mutableCopy];
            jsonDict[@"CreatedDateTime"] = [self.defaultDotNetDateFormatter stringFromDate:[NSDate date]];
            jsonDict[@"LastUpdatedDateTime"] = [self.defaultDotNetDateFormatter stringFromDate:[NSDate date]];
            jsonDict[@"CreditBalance"] = @0;
            
            if (!error) {
                // user converted, prepare to POST to server
                
                NSMutableURLRequest *userPostRequest = [NSMutableURLRequest requestWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
                userPostRequest.HTTPMethod = @"POST";
                [userPostRequest setValue:self.facebookToken forHTTPHeaderField:@"Authorization"];
                [userPostRequest setValue:appUser.fbID forHTTPHeaderField:@"FacebookId"];
                userPostRequest.HTTPBody = [RKMIMETypeSerialization dataFromObject:jsonDict MIMEType:RKMIMETypeJSON error:&error];
                [userPostRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                if (error) {
                    DDLogError(@"JSON serialization problem during initial user creation: %@", error);
                }
                
                AFJSONRequestOperation *userPostOperation = [[AFJSONRequestOperation alloc] initWithRequest:userPostRequest];
                [userPostOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    // map the response to existing user managed object
                    self.appToken = operation.response.allHeaderFields[@"Authorization"];  // update the app token
                    
                    NSDictionary *responseDict = [responseObject isKindOfClass:NSArray.class] && ((NSArray *)responseObject).count > 0 ? responseObject[0] : responseObject;
                    RKMappingOperation *mappingOperation = [[RKMappingOperation alloc] initWithSourceObject:responseDict destinationObject:appUser mapping:[MUserInfo appEntityMapping]];
                    NSError *error = nil;
                    [mappingOperation performMapping:&error];
                    if (!error) {
                        DDLogInfo(@"successfully created app user and set info");
                        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
                            [handler restManagerService:_cmd succeededWithOperation:operation userInfo:nil];
                        }
                    } else {
                        DDLogError(@"error in creating app user during deserialization: %@", error);
                        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
                            [handler restManagerService:_cmd failedWithOperation:mappingOperation error:error userInfo:nil];
                        }
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    DDLogError(@"error in initial user creation - posting to server: %@", error);
                    if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
                        [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
                    }
                }];
                [userPostOperation start];
            } else {
                DDLogError(@"error in initial user creation - convert from facebook user: %@", error);
                if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
                    [handler restManagerService:_cmd failedWithOperation:nil error:error userInfo:nil];
                }
            }
        } else {
            // user already exists on server side, map the response to the existing user managed object
            self.appToken = operation.response.allHeaderFields[@"Authorization"];  // update the app token
            
            NSDictionary *responseDict = [responseObject isKindOfClass:NSArray.class] && ((NSArray *)responseObject).count > 0 ? responseObject[0] : responseObject;
            RKMappingOperation *mappingOperation = [[RKMappingOperation alloc] initWithSourceObject:responseDict destinationObject:appUser mapping:[MUserInfo appEntityMapping]];
            NSError *error = nil;
            [mappingOperation performMapping:&error];
            if (!error) {
                DDLogInfo(@"successfully updated app user info");
                if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
                    [handler restManagerService:_cmd succeededWithOperation:operation userInfo:nil];
                }
            } else {
                DDLogError(@"error in updating app user info during deserialization: %@", error);
                if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
                    [handler restManagerService:_cmd failedWithOperation:mappingOperation error:error userInfo:nil];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"REST operation failed: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    [operation start];
}

@end
