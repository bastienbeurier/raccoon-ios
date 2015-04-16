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

+ (UIImage *)getCachedImage:(NSInteger)identifier;

+ (void)setCachedImage:(UIImage *)image forId:(NSInteger)identifier;

@end
