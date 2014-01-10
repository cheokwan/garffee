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
#import "SecurityManager.h"
#import "MBranch.h"

@interface RestManager()
@property (nonatomic, strong)   RKObjectManager *facebookObjectManager;
@property (nonatomic, strong)   RKObjectManager *appObjectManager;
@end

@implementation RestManager
@synthesize appToken = _appToken;
@synthesize defaultDotNetValueTransformer = _defaultDotNetValueTransformer;
@synthesize defaultDotNetDateFormatter = _defaultDotNetDateFormatter;

#pragma mark - Internal

+ (instancetype)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static id instance = nil;
    dispatch_once(&token, ^{
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);  // XXX-TEST
        instance = [[self alloc] init];
    });
    return instance;
}

- (RKObjectManager *)facebookObjectManager {
    if (!_facebookObjectManager) {
        self.facebookObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:(NSString *)facebookAPIBaseURLString]];
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
    if (appToken && appToken.length > 0) {
        _appToken = appToken;
        
        // persist to key chain
        NSData *tokenData = [SecurityManager searchKeychainCopyMatching:SecurityManagerIdAppToken];
        if (tokenData) {
            [SecurityManager updateKeychainValue:_appToken forIdentifier:SecurityManagerIdAppToken];
        } else {
            [SecurityManager createKeychainValue:_appToken forIdentifier:SecurityManagerIdAppToken];
        }
    }
}

- (NSString *)appToken {
    if (!_appToken || _appToken.length == 0) {
        // first try to retrieve from key chain if there's any
        NSData *tokenData = [SecurityManager searchKeychainCopyMatching:SecurityManagerIdAppToken];
        if (tokenData) {
            _appToken = [[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
        }
    }
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

- (void)fetchManagedObjectsWithServiceHost:(RestManagerServiceHostType)serviceHost endPoint:(NSString *)endPoint sourceSelector:(SEL)sourceSelector responseDescriptors:(NSArray *)responseDescriptors handler:(__weak id<RestManagerResponseHandler>)handler {
    NSMutableURLRequest *request = nil;
    RKObjectManager *objectManager = nil;
    switch (serviceHost) {
        case RestManagerServiceHostApp: {
            NSURL *serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingPathComponent:endPoint]];
            request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
            [request setValue:self.appToken forHTTPHeaderField:@"Authorization"];
            objectManager = self.appObjectManager;
        }
            break;
        case RestManagerServiceHostFacebook: {
            NSURL *serviceURL = [NSURL URLWithString:[facebookAPIBaseURLString stringByAppendingPathComponent:endPoint]];
            request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
            objectManager = self.facebookObjectManager;
        }
            break;
    }
    
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:responseDescriptors];
    operation.managedObjectContext = [AppDelegate sharedAppDelegate].managedObjectContext;
    operation.managedObjectCache = [RKManagedObjectStore defaultStore].managedObjectCache;
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            NSDictionary *userInfo = mappingResult ? @{@"mappingResult": mappingResult} : nil;
            [handler restManagerService:sourceSelector succeededWithOperation:operation userInfo:userInfo];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DDLogError(@"REST operation failed: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:sourceSelector failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    [objectManager enqueueObjectRequestOperation:operation];
}

#pragma mark - Facebook Services

- (void)fetchFacebookAppUserInfo:(__weak id<RestManagerResponseHandler>)handler {
    // fetch user info
    NSString *endPoint = [NSString stringWithFormat:@"/me/?access_token=%@&fields=id,name,username,email,first_name,middle_name,last_name,gender,age_range,link,locale,birthday,picture.width(200),picture.height(200)", self.facebookToken];
    [self fetchManagedObjectsWithServiceHost:RestManagerServiceHostFacebook endPoint:endPoint sourceSelector:_cmd responseDescriptors:@[[MUserFacebookInfo defaultResponseDescriptor]] handler:handler];
}


- (void)fetchFacebookFriendsInfo:(__weak id<RestManagerResponseHandler>)handler {
    // fetch friends info
    NSString *endPoint = [NSString stringWithFormat:@"/me/friends?access_token=%@&fields=id,name,username,email,first_name,middle_name,last_name,gender,age_range,link,locale,birthday,picture.width(200),picture.height(200)", self.facebookToken];
    [self fetchManagedObjectsWithServiceHost:RestManagerServiceHostFacebook endPoint:endPoint sourceSelector:_cmd responseDescriptors:@[[MUserFacebookInfo fetchFriendsResponseDescriptor]] handler:handler];
}

#pragma mark - App Services

// TODO: handle the new login flow with native account support, currently this assumes
// we always fetch the app user with facebook credentials
- (void)fetchAppUserInfo:(__weak id<RestManagerResponseHandler>)handler {
    NSURL *serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingString:@"/users"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    MUserFacebookInfo *appUser = [MUserFacebookInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    [request setValue:self.facebookToken forHTTPHeaderField:@"Authorization"];
    [request setValue:appUser.fbID forHTTPHeaderField:@"FacebookId"];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // responseObject is JSON
        BOOL emptyResponse = [responseObject performSelector:@selector(count)] == 0;  // JSON is either array or dict
        if (emptyResponse) {
            // user does not exist on server side, convert the facebook user to create a new one
            DDLogInfo(@"fetch app user info returns empty response, going to create a new app user");
            
            RKRequestDescriptor *serialization = [RKRequestDescriptor requestDescriptorWithMapping:[MUserFacebookInfo appUserCreationEntityMapping] objectClass:MUserFacebookInfo.class rootKeyPath:nil method:RKRequestMethodPOST];
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
                AFJSONRequestOperation *userPostOperation = nil;
                if (error) {
                    DDLogError(@"JSON serialization problem during initial user creation: %@", error);
                } else {
                    userPostOperation = [[AFJSONRequestOperation alloc] initWithRequest:userPostRequest];
                }
                
                [userPostOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    // map the response to existing user managed object
                    self.appToken = operation.response.allHeaderFields[@"Authorization"];  // update the app token
                    
                    NSDictionary *responseDict = [responseObject isKindOfClass:NSArray.class] && ((NSArray *)responseObject).count > 0 ? responseObject[0] : responseObject;
                    RKMappingOperation *mappingOperation = [[RKMappingOperation alloc] initWithSourceObject:responseDict destinationObject:appUser mapping:[MUserInfo defaultEntityMapping]];
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
            RKMappingOperation *mappingOperation = [[RKMappingOperation alloc] initWithSourceObject:responseDict destinationObject:appUser mapping:[MUserInfo defaultEntityMapping]];
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

- (void)fetchAppProductInfo:(__weak id<RestManagerResponseHandler>)handler {
    [self fetchManagedObjectsWithServiceHost:RestManagerServiceHostApp endPoint:@"/products" sourceSelector:_cmd responseDescriptors:@[[MProductInfo defaultResponseDescriptor]] handler:handler];
}

- (void)fetchAppConfigurations:(__weak id<RestManagerResponseHandler>)handler {
    [self fetchManagedObjectsWithServiceHost:RestManagerServiceHostApp endPoint:@"/configurations" sourceSelector:_cmd responseDescriptors:@[[MGlobalConfiguration defaultResponseDescriptor]] handler:handler];
}

- (void)fetchBranches:(__weak id<RestManagerResponseHandler>)handler {
    [self fetchManagedObjectsWithServiceHost:RestManagerServiceHostApp endPoint:@"/storebranches" sourceSelector:_cmd responseDescriptors:@[[MBranch defaultResponseDescriptor]] handler:handler];
}

- (void)fetchAppCouponInfo:(__weak id<RestManagerResponseHandler>)handler {
    [self fetchManagedObjectsWithServiceHost:RestManagerServiceHostApp endPoint:@"/coupons" sourceSelector:_cmd responseDescriptors:@[[MCouponInfo defaultResponseDescriptor]] handler:handler];
}


- (void)postOrder:(MOrderInfo *)order handler:(__weak id<RestManagerResponseHandler>)handler {
    NSURL *serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingPathComponent:@"/orders"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    request.HTTPMethod = @"POST";
    [request setValue:self.appToken forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    RKRequestDescriptor *serialization = [RKRequestDescriptor requestDescriptorWithMapping:[[MOrderInfo defaultEntityMapping] inverseMapping] objectClass:MOrderInfo.class rootKeyPath:nil method:RKRequestMethodPOST];
    NSError *error = nil;
    NSMutableDictionary *jsonDict = [[RKObjectParameterization parametersWithObject:order requestDescriptor:serialization error:&error] mutableCopy];
    
    AFJSONRequestOperation *operation = nil;
    if (error) {
        DDLogError(@"JSON parameterization problem during posting order: %@", error);
    } else {
        request.HTTPBody = [RKMIMETypeSerialization dataFromObject:jsonDict MIMEType:RKMIMETypeJSON error:&error];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        if (error) {
            DDLogError(@"JSON serialization problem during posting order: %@", error);
        } else {
            operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
        }
    }
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
            MOrderInfo *takenOrder = [MOrderInfo newOrderInfoInContext:context];
            NSDictionary *responseDict = [responseObject isKindOfClass:NSArray.class] && ((NSArray *)responseObject).count > 0 ? responseObject[0] : responseObject;
            RKMappingOperation *mappingOperation = [[RKMappingOperation alloc] initWithSourceObject:responseDict destinationObject:takenOrder mapping:[MOrderInfo defaultEntityMapping]];
            RKManagedObjectMappingOperationDataSource *dataSource = [[RKManagedObjectMappingOperationDataSource alloc] initWithManagedObjectContext:context cache:[RKManagedObjectStore defaultStore].managedObjectCache];
            mappingOperation.dataSource = dataSource;
            NSError *error = nil;
            [mappingOperation performMapping:&error];
            if (!error) {
                DDLogInfo(@"successfully received and deserialized taken order: %@", takenOrder.id);
                if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
                    NSDictionary *userInfo = responseObject ? @{@"responseObject": responseObject} : nil;
                    [handler restManagerService:_cmd succeededWithOperation:operation userInfo:userInfo];
                }
            } else {
                DDLogError(@"error in deserializaing taken order: %@", error);
                if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
                    [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
                }
            }
        } else {
            DDLogError(@"empty response from posted order");
            if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
                [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
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
