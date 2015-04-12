//
//  RACApi.h
//  Raccoon
//
//  Created by Bastien Beurier on 4/12/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface RACApi : AFHTTPSessionManager

+ (RACApi *)sharedClient;

+ (void)getRecipes:(NSInteger)count
           orderBy:(NSString *)orderBy
            offset:(NSInteger)offset
           success:(void(^)(NSArray *recipes))success
           failure:(void(^)())failure;
@end
