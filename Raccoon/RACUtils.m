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

@end
