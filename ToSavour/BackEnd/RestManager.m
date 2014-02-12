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
        } else {
            // TODO: handle if tokenData is not found
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

- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return _operationQueue;
}


#pragma mark - Services

// TODO: support fetching outside of non-mainqueue contexts

- (NSMutableURLRequest *)requestWithServiceHostType:(RestManagerServiceHostType)serviceHostType endPoint:(NSString *)endPoint {
    NSURL *serviceURL = nil;
    switch (serviceHostType) {
        case RestManagerServiceHostApp:
            serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingPathComponent:endPoint]];
            break;
        case RestManagerServiceHostFacebook:
            serviceURL = [NSURL URLWithString:[facebookAPIBaseURLString stringByAppendingPathComponent:endPoint]];
            break;
        default:
            break;
    }
    // default values
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (serviceHostType == RestManagerServiceHostApp) {
        [request setValue:self.appToken forHTTPHeaderField:@"Authorization"];
    }
    return request;
}

- (void)startOperation:(RKObjectRequestOperation *)operation sourceSelector:(SEL)sourceSelector handler:(__weak id<RestManagerResponseHandler>)handler {
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        DDLogDebug(@"REST operation %@ succeeded", NSStringFromSelector(sourceSelector));
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
    [self.operationQueue addOperation:operation];
}

- (void)fetchManagedObjectsWithRequest:(NSURLRequest *)request context:(NSManagedObjectContext *)context sourceSelector:(SEL)sourceSelector responseDescriptors:(NSArray *)responseDescriptors persist:(BOOL)persist handler:(__weak id<RestManagerResponseHandler>)handler {
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:responseDescriptors];
    operation.managedObjectContext = context;
    operation.managedObjectCache = [RKManagedObjectStore defaultStore].managedObjectCache;
    if (!persist) {
        operation.savesToPersistentStore = NO;
    }
    [self startOperation:operation sourceSelector:sourceSelector handler:handler];
}

- (void)fetchObjectWithRequest:(NSURLRequest *)request sourceSelector:(SEL)sourceSelector responseDescriptors:(NSArray *)responseDescriptors handler:(__weak id<RestManagerResponseHandler>)handler {
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:responseDescriptors];
    [self startOperation:operation sourceSelector:sourceSelector handler:handler];
}


#pragma mark - Facebook Services

- (void)fetchFacebookAppUserInfo:(__weak id<RestManagerResponseHandler>)handler {
    // fetch user info
    NSString *endPoint = [NSString stringWithFormat:@"/me/?access_token=%@&fields=id,name,username,email,first_name,middle_name,last_name,gender,age_range,link,locale,birthday,picture.width(200),picture.height(200)", self.facebookToken];
    NSURLRequest *request = [self requestWithServiceHostType:RestManagerServiceHostFacebook endPoint:endPoint];
    [self fetchManagedObjectsWithRequest:request context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MUserFacebookInfo defaultResponseDescriptor]] persist:YES handler:handler];
}


- (void)fetchFacebookFriendsInfo:(__weak id<RestManagerResponseHandler>)handler {
    // fetch friends info
    NSString *endPoint = [NSString stringWithFormat:@"/me/friends?access_token=%@&fields=id,name,username,email,first_name,middle_name,last_name,gender,age_range,link,locale,birthday,picture.width(200),picture.height(200)", self.facebookToken];
    NSURLRequest *request = [self requestWithServiceHostType:RestManagerServiceHostFacebook endPoint:endPoint];
    [self fetchManagedObjectsWithRequest:request context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MUserFacebookInfo fetchFriendsResponseDescriptor]] persist:YES handler:handler];
}

#pragma mark - App Services

#pragma mark - Fetching Remote Data

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
    [self fetchManagedObjectsWithRequest:[self requestWithServiceHostType:RestManagerServiceHostApp endPoint:@"/products"] context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MProductInfo defaultResponseDescriptor]] persist:YES handler:handler];
}

- (void)fetchAppConfigurations:(__weak id<RestManagerResponseHandler>)handler {
    [self fetchManagedObjectsWithRequest:[self requestWithServiceHostType:RestManagerServiceHostApp endPoint:@"/configurations"] context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MGlobalConfiguration defaultResponseDescriptor]] persist:YES handler:handler];
}

- (void)fetchBranches:(__weak id<RestManagerResponseHandler>)handler {
    [self fetchManagedObjectsWithRequest:[self requestWithServiceHostType:RestManagerServiceHostApp endPoint:@"/storebranches"] context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MBranch defaultResponseDescriptor]] persist:YES handler:handler];
}

- (void)fetchAppCouponInfo:(__weak id<RestManagerResponseHandler>)handler {
    [self fetchManagedObjectsWithRequest:[self requestWithServiceHostType:RestManagerServiceHostApp endPoint:@"/coupons"] context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MCouponInfo defaultResponseDescriptor]] persist:YES handler:handler];
}

- (void)fetchAppOrderHistories:(__weak id<RestManagerResponseHandler>)handler {
    [self fetchManagedObjectsWithRequest:[self requestWithServiceHostType:RestManagerServiceHostApp endPoint:@"/orderhistories"] context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MOrderInfo defaultResponseDescriptor]] persist:YES handler:handler];
}

- (void)fetchAppPendingOrderStatus:(__weak id<RestManagerResponseHandler>)handler {
    NSFetchRequest *fetchRequest = [MOrderInfo fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"status IN[c] %@", @[MOrderInfoStatusPending, MOrderInfoStatusInProgress, MOrderInfoStatusFinished]];
    NSError *error = nil;
    NSArray *ongoingOrders = [[AppDelegate sharedAppDelegate].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DDLogError(@"error fetching ongong orders while fetching remote order status: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:nil error:error userInfo:nil];
        }
    }
    
    for (MOrderInfo *order in ongoingOrders) {
        if ([order.id longValue] > 0) {
            NSMutableURLRequest *request = [self requestWithServiceHostType:RestManagerServiceHostApp endPoint:[NSString stringWithFormat:@"/orders/%@", [order.id stringValue]]];
            [self fetchManagedObjectsWithRequest:request context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MOrderInfo defaultResponseDescriptor]] persist:YES handler:handler];
        } else {
            DDLogWarn(@"ongoing order has no order id: %@", order);
        }
    }
}

#pragma mark - Putting Data

- (void)putUserInfo:(MUserInfo *)userInfo handler:(__weak id<RestManagerResponseHandler>)handler {
    userInfo.isDirty = NO;
    [userInfo.managedObjectContext save];
    
    NSMutableURLRequest *request = [self requestWithServiceHostType:RestManagerServiceHostApp endPoint:[NSString stringWithFormat:@"/users/%@", userInfo.appID]];
    request.HTTPMethod = @"PUT";
    
    RKRequestDescriptor *serialization = [RKRequestDescriptor requestDescriptorWithMapping:[MUserInfo putUserInfoMapping] objectClass:MUserInfo.class rootKeyPath:nil method:RKRequestMethodPUT];
    NSError *error = nil;
    NSMutableDictionary *jsonDict = [[RKObjectParameterization parametersWithObject:userInfo requestDescriptor:serialization error:&error] mutableCopy];
    
    if (error) {
        DDLogError(@"JSON parameterization problem during posting order: %@", error);
    } else {
        request.HTTPBody = [RKMIMETypeSerialization dataFromObject:jsonDict MIMEType:RKMIMETypeJSON error:&error];
        if (error) {
            DDLogError(@"JSON serialization problem during posting order: %@", error);
        }
    }
    [self fetchManagedObjectsWithRequest:request context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MUserInfo defaultResponseDescriptor]] persist:NO handler:handler];
}

#pragma mark - Posting Data

- (void)postOrder:(MOrderInfo *)order handler:(__weak id<RestManagerResponseHandler>)handler {
    NSMutableURLRequest *request = [self requestWithServiceHostType:RestManagerServiceHostApp endPoint:@"/orders"];
    request.HTTPMethod = @"POST";
    
    RKRequestDescriptor *serialization = [RKRequestDescriptor requestDescriptorWithMapping:[[MOrderInfo defaultEntityMapping] inverseMapping] objectClass:MOrderInfo.class rootKeyPath:nil method:RKRequestMethodPOST];
    NSError *error = nil;
    NSMutableDictionary *jsonDict = [[RKObjectParameterization parametersWithObject:order requestDescriptor:serialization error:&error] mutableCopy];
    
    if (error) {
        DDLogError(@"JSON parameterization problem during posting order: %@", error);
    } else {
        request.HTTPBody = [RKMIMETypeSerialization dataFromObject:jsonDict MIMEType:RKMIMETypeJSON error:&error];
        if (error) {
            DDLogError(@"JSON serialization problem during posting order: %@", error);
        }
    }
    
    [self fetchManagedObjectsWithRequest:request context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MOrderInfo defaultResponseDescriptor]] persist:NO handler:handler];
}

- (void)postGiftCoupon:(MOrderInfo *)order handler:(__weak id<RestManagerResponseHandler>)handler {
    NSMutableURLRequest *request = [self requestWithServiceHostType:RestManagerServiceHostApp endPoint:@"/coupons"];
    request.HTTPMethod = @"POST";
    
    // XXXXXX
    for (MItemInfo *item in order.items) {
        // XXX-SERVER-BUG: need to change the orderID into nullable foreign key
        item.orderID = @3222;
    }
    
    RKRequestDescriptor *serialization = [RKRequestDescriptor requestDescriptorWithMapping:[MOrderInfo giftCouponCreationEntityMapping] objectClass:MOrderInfo.class rootKeyPath:nil method:RKRequestMethodPOST];
    NSError *error = nil;
    NSMutableDictionary *jsonDict = [[RKObjectParameterization parametersWithObject:order requestDescriptor:serialization error:&error] mutableCopy];
    MUserInfo *appUser = [MUserInfo currentAppUserInfoInContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    [jsonDict setValue:appUser.appID forKey:@"SenderUserId"];
    
    if (error) {
        DDLogError(@"JSON parameterization problem during posting gift coupon: %@", error);
    } else {
        request.HTTPBody = [RKMIMETypeSerialization dataFromObject:jsonDict MIMEType:RKMIMETypeJSON error:&error];
        if (error) {
            DDLogError(@"JSON serialization problem during posting gift coupon: %@", error);
        }
    }
    
    // TODO: we don't need to store the returned coupon
    [self fetchManagedObjectsWithRequest:request context:[AppDelegate sharedAppDelegate].managedObjectContext sourceSelector:_cmd responseDescriptors:@[[MCouponInfo defaultResponseDescriptor]] persist:YES handler:handler];
}

#pragma mark - Query type

- (void)queryFacebookContactsInContext:(NSManagedObjectContext *)context handler:(__weak id<RestManagerResponseHandler>)handler {
    NSMutableURLRequest *request = [self requestWithServiceHostType:RestManagerServiceHostApp endPoint:@"/memberids/facebookid"];
    request.HTTPMethod = @"POST";
    
    NSFetchRequest *fetchRequest = [MUserFacebookInfo fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"appID = %@", nil];
    NSError *error = nil;
    NSArray *facebookContacts = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DDLogError(@"error fetching facebook contacts: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:nil error:error userInfo:nil];
            return;
        }
    } else if (facebookContacts.count == 0) {
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            [handler restManagerService:_cmd succeededWithOperation:nil userInfo:nil];
        }
        return;
    }
    
    NSMutableArray *allFacebookIDs = [NSMutableArray array];
    [facebookContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MUserFacebookInfo *user = (MUserFacebookInfo *)obj;
        if (user.fbID.length > 0) {
            [allFacebookIDs addObject:user.fbID];
        }
    }];
    
    // TODO: if there's too many facebook IDs, may need to separate fetch into stages
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:allFacebookIDs options:0 error:&error];
    if (error) {
        DDLogError(@"error serializating facebook contacts IDs to JSON: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:nil error:error userInfo:nil];
            return;
        }
    }
    
    request.HTTPBody = jsonData;
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    DDLogDebug(@"query facebook contacts JSON body: %@", jsonString);
    
    [self fetchObjectWithRequest:request sourceSelector:_cmd responseDescriptors:@[[KVPair defaultResponseDescriptor]] handler:handler];
}

- (void)queryAddressBookContactsInContext:(NSManagedObjectContext *)context handler:(__weak id<RestManagerResponseHandler>)handler {
    NSMutableURLRequest *request = [self requestWithServiceHostType:RestManagerServiceHostApp endPoint:@"/memberids/phonenumber"];
    request.HTTPMethod = @"POST";
    
    NSFetchRequest *fetchRequest = [MUserAddressBookInfo fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"appID = %@", nil];
    NSError *error = nil;
    NSArray *phoneContacts = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DDLogError(@"error fetching phone contacts: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:nil error:error userInfo:nil];
            return;
        }
    } else if (phoneContacts.count == 0) {
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            [handler restManagerService:_cmd succeededWithOperation:nil userInfo:nil];
        }
        return;
    }
    
    NSMutableArray *allPhoneNumbers = [NSMutableArray array];
    [phoneContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MUserAddressBookInfo *user = (MUserAddressBookInfo *)obj;
        NSArray *numbers = [user.abCanonicalPhoneNumbers decodeCommaSeparatedString];
        if (numbers.count > 0) {
            [allPhoneNumbers addObjectsFromArray:numbers];
        }
    }];
    
    // TODO: if there's too many contacts phone numbers, may need to separate fetch into stages
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:allPhoneNumbers options:0 error:&error];
    if (error) {
        DDLogError(@"error serializating phone contacts numbers to JSON: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:nil error:error userInfo:nil];
            return;
        }
    }
    
    request.HTTPBody = jsonData;
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    DDLogDebug(@"query phone contacts JSON body: %@", jsonString);
    
    [self fetchObjectWithRequest:request sourceSelector:_cmd responseDescriptors:@[[KVPair defaultResponseDescriptor]] handler:handler];
}

@end



@implementation KVPair
+ (RKObjectMapping *)defaultObjectMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self.class];
    [mapping addAttributeMappingsFromDictionary:@{@"Key": @"key",
                                                  @"Value": @"value"}];
    return mapping;
}
+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultObjectMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}
@end