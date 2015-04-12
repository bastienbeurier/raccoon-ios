//
//  Card.m
//  Raccoon
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACRecipe.h"

#define ID @"id"
#define TITLE @"title"
#define HEALTHINESS @"healthiness"
#define PREPARATION @"preparation"
#define PRICE @"price"
#define IMAGE @"image_url"
#define INGREDIENTS @"ingredients"
#define STEPS @"steps"
#define DESCRIPTION @"description"

@implementation RACRecipe

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.imageUrl = nil;
        self.title = @"";
    }
    
    return self;
}

+ (NSArray *)rawsToInstances:(NSArray *)raws
{
    NSMutableArray *instances = [NSMutableArray new];
    
    for (NSDictionary *raw in raws) {
        [instances addObject:[RACRecipe rawToInstance:raw]];
    }
    
    return instances;
}

+ (RACRecipe *)rawToInstance:(NSDictionary *)raw {
    RACRecipe *instance = [RACRecipe new];
    
    instance.identifier = [[raw objectForKey:ID] integerValue];
    instance.title = [raw objectForKey:TITLE];
    instance.healthiness = [[raw objectForKey:HEALTHINESS] integerValue];
    instance.preparation = [[raw objectForKey:PREPARATION] integerValue];
    instance.price = [[raw objectForKey:PRICE] integerValue];
    instance.imageUrl = [raw objectForKey:IMAGE];
    
    instance.ingredients = [NSMutableArray new];
    instance.steps = [NSMutableArray new];
    
    for (NSDictionary *ingredient in [raw objectForKey:INGREDIENTS]) {
        [instance.ingredients addObject:[ingredient objectForKey:DESCRIPTION]];
    }
    
    for (NSDictionary *step in [raw objectForKey:STEPS]) {
        [instance.steps addObject:[step objectForKey:DESCRIPTION]];
    }
    
    return instance;
}

@end
