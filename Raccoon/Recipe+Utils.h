//
//  Recipe+Utils.h
//  Raccoon
//
//  Created by Bastien Beurier on 4/17/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Recipe.h"

@interface Recipe (Utils)

+ (NSArray *)getLocalRecipesWithContext:(NSManagedObjectContext *)context;
+ (NSArray *)syncLocalRecipes:(NSArray *)localRecipes withServerRecipes:(NSArray *)serverRecipes forContext:(NSManagedObjectContext *)context;

@end