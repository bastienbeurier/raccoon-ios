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

+ (UIImage *)getCachedImage:(NSNumber *)identifier {
    NSString *cachedImagesPath = [RACUtils getImagesDirectoryPath];
    NSString *imagePath = [cachedImagesPath stringByAppendingString:[NSString stringWithFormat:@"%@", identifier]];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    UIImage *image = nil;
    
    //Image has been cached.
    if ([fileManager isReadableFileAtPath:imagePath]) {
        NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:imagePath];
        image = [UIImage imageWithData:[handle readDataToEndOfFile]];
    }

    return image;
}

+ (void)setCachedImage:(NSData *)imageData forId:(NSNumber *)identifier {
    if (!imageData) {
        return;
    }
    
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
    
    NSString *newImagePath = [cachedImagesPath stringByAppendingString:[NSString stringWithFormat:@"%@", identifier]];
    [fileManager createFileAtPath:newImagePath contents:imageData attributes:nil];
}

+ (NSString *)getImagesDirectoryPath {
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cachesPath stringByAppendingString:@"/RaccoonImages/"];
}

+ (NSURL *)getDocumentDirectoryPath {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *url = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    return [url URLByAppendingPathComponent:@"Model"];
}

+ (void)getManagedObjectContextSuccess:(void(^)(NSManagedObjectContext *))successBlock failure:(void(^)(void))failureBlock {
    NSURL *url = [RACUtils getDocumentDirectoryPath];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    if ([[[NSFileManager alloc] init] fileExistsAtPath:[url path]]) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                if (document.documentState == UIDocumentStateNormal) {
                    successBlock(document.managedObjectContext);
                } else {
                    failureBlock();
                }
            } else {
                failureBlock();
            }
        }];
    } else {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                if (document.documentState == UIDocumentStateNormal) {
                    successBlock(document.managedObjectContext);
                } else {
                    failureBlock();
                }
            } else {
                failureBlock();
            }
        }];
    }
}

@end
