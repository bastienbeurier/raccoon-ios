//
//  RACApi.m
//  Raccoon
//
//  Created by Bastien Beurier on 4/12/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACApi.h"
#import "RACConstants.h"
#import "RACRecipe.h"

@implementation RACApi

+ (RACApi *)sharedClient
{
    static RACApi *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[RACApi alloc] initWithBaseURL:[NSURL URLWithString:kApiBaseUrl]];
        
        // Add m4a content type for audio
        _sharedClient.responseSerializer.acceptableContentTypes = [_sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"audio/m4a"];
        
        // Stop request if we lose connection
        NSOperationQueue *operationQueue = _sharedClient.operationQueue;
        [_sharedClient.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if(status == AFNetworkReachabilityStatusNotReachable) {
                [operationQueue cancelAllOperations];
            }
        }];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

+ (NSString *)getBasePath
{
    return [NSString stringWithFormat:@"api/v%@/", kApiVersion];
}

+ (void)getRecipes:(NSInteger)count
           orderBy:(NSString *)orderBy
            offset:(NSInteger)offset
           success:(void(^)(NSArray *recipes))success
           failure:(void(^)())failure
{
    NSString *path =  [[RACApi getBasePath] stringByAppendingString:@"recipes.json"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:[NSNumber numberWithLong:count] forKey:@"count"];
    [parameters setObject:[NSNumber numberWithLong:offset] forKey:@"offset"];
    [parameters setObject:orderBy forKey:@"order_by"];
    
    [[RACApi sharedClient] GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
        NSDictionary *result = [JSON valueForKeyPath:@"result"];
        
        NSArray *rawRecipes = [result objectForKey:@"recipes"];
        
        if (success) {
            success([RACRecipe rawsToInstances:rawRecipes]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task);
        }
    }];
}

@end
