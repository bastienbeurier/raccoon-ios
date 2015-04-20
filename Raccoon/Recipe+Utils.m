//
//  Recipe+Utils.m
//  Raccoon
//
//  Created by Bastien Beurier on 4/17/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "Recipe+Utils.h"
#import "RACUtils.h"
#import "Ingredient.h"
#import "Step.h"

#define ID @"id"
#define TITLE @"title"
#define IMAGE @"image_url"
#define INGREDIENTS @"ingredients"
#define STEPS @"steps"
#define DESCRIPTION @"description"

@implementation Recipe (Utils)

+ (Recipe *)insertNewRecipeWithRawData:(NSDictionary *)raw context:(NSManagedObjectContext *)context {
    Recipe *instance = [NSEntityDescription insertNewObjectForEntityForName:@"Recipe" inManagedObjectContext:context];
    
    instance.identifier = @([[raw objectForKey:ID] intValue]);
    instance.title = [raw objectForKey:TITLE];
    instance.imageUrl = [raw objectForKey:IMAGE];
    
    for (NSDictionary *rawIngredient in [raw objectForKey:INGREDIENTS]) {
        Ingredient *ingredient = [NSEntityDescription insertNewObjectForEntityForName:@"Ingredient" inManagedObjectContext:context];
        ingredient.desc = [rawIngredient objectForKey:DESCRIPTION];
        [instance addIngredientsObject:ingredient];
    }
    
    for (NSDictionary *rawStep in [raw objectForKey:STEPS]) {
        Step *step = [NSEntityDescription insertNewObjectForEntityForName:@"Step" inManagedObjectContext:context];
        step.desc = [rawStep objectForKey:DESCRIPTION];
        [instance addStepsObject:step];
    }
    
    return instance;
}

+ (NSArray *)getLocalRecipesWithContext:(NSManagedObjectContext *)context {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
    
    NSError *error;
    NSArray *recipes = [context executeFetchRequest:request error:&error];
    
    if (error) {
        return nil;
    }
    
    return recipes;
}

+ (NSArray *)syncLocalRecipes:(NSArray *)localRecipes withServerRecipes:(NSArray *)serverRecipes forContext:(NSManagedObjectContext *)context {
    NSError *error;
    
    NSMutableSet *serverIds = [NSMutableSet new];
    NSMutableSet *localIds = [NSMutableSet new];
    
    //Put server recipe identifiers in set to check for membership.
    for (NSDictionary *rawRecipe in serverRecipes) {
        [serverIds addObject:[rawRecipe objectForKey:@"id"]];
    }
    
    //Put local recipe identifiers in set to check for membership.
    for (Recipe *recipe in localRecipes) {
        [localIds addObject:[NSString stringWithFormat:@"%@", recipe.identifier]];
    }
    
    //Add recipes coming from server.
    for (NSDictionary *rawRecipe in serverRecipes) {
        if (![localIds containsObject:[rawRecipe objectForKey:@"id"]]) {
            [Recipe insertNewRecipeWithRawData:rawRecipe context:context];
        }
    }
    
    //Remove recipes that are no longer on server.
    for (Recipe *recipe in localRecipes) {
        if (![serverIds containsObject:[NSString stringWithFormat:@"%@", recipe.identifier]]) {
            [context deleteObject:recipe];
        }
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
    return [context executeFetchRequest:request error:&error];
}

@end
