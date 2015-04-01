//
//  CrossDissolveSegue.m
//  Raccoon
//
//  Created by Bastien Beurier on 4/1/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "CrossDissolveSegue.h"

@implementation CrossDissolveSegue

- (void)perform
{
    UIViewController *controller = [self destinationViewController];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[self sourceViewController] presentModalViewController:controller animated:YES];
}

@end
