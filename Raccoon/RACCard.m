//
//  Card.m
//  Raccoon
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACCard.h"

@implementation RACCard

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.imageUrl = nil;
        self.title = @"";
        self.ingredients = @"";
    }
    
    return self;
}

@end
