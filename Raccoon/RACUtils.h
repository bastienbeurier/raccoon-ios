//
//  RACUtils.h
//  Raccoon
//
//  Created by Bastien Beurier on 4/13/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RACUtils : NSObject

+ (void)showMessage:(NSString *)message
      forController:(UIViewController *)controller
          withTitle:(NSString *)title
             action:(NSString *)action
         completion:(void(^)())completion;

+ (UIImage *)getCachedImage:(NSNumber *)identifier;

+ (void)setCachedImage:(NSData *)imageData forId:(NSNumber *)identifier;

+ (void)getManagedObjectContextSuccess:(void(^)(NSManagedObjectContext *))successBlock failure:(void(^)(void))failureBlock;

@end
