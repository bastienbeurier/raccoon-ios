//
//  RACUtils.m
//  Raccoon
//
//  Created by Bastien Beurier on 4/13/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACUtils.h"

@implementation RACUtils

+ (void)showMessage:(NSString *)message
      forController:(UIViewController *)controller
          withTitle:(NSString *)title
             action:(NSString *)actionTitle
         completion:(void(^)())completion {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:actionTitle
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   completion();
                                               }];
    [alertController addAction:action];
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (UIImage *)getCachedImage:(NSInteger)identifier {
    NSString *cachedImagesPath = [RACUtils getImagesDirectoryPath];
    NSString *newImagePath = [cachedImagesPath stringByAppendingString:[NSString stringWithFormat:@"%ld", identifier]];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    //Image has been cached.
    if ([fileManager isReadableFileAtPath:newImagePath]) {
        NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:newImagePath];
        return [UIImage imageWithData:[handle readDataToEndOfFile]];
    }
    
    //Image has not been cached yet.
    return nil;
}

+ (void)setCachedImage:(UIImage *)image forId:(NSInteger)identifier {
    NSString *cachedImagesPath = [RACUtils getImagesDirectoryPath];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    //Create an images cache directory if needed.
    if (![fileManager fileExistsAtPath:cachedImagesPath]) {
        NSError *error;
        [fileManager createDirectoryAtPath:cachedImagesPath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            return;
        }
    }
    
    NSString *newImagePath = [cachedImagesPath stringByAppendingString:[NSString stringWithFormat:@"%ld", identifier]];
    [fileManager createFileAtPath:newImagePath contents:UIImagePNGRepresentation(image) attributes:nil];
}

+ (NSString *)getImagesDirectoryPath {
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cachesPath stringByAppendingString:@"RaccoonImages"];
}

@end
