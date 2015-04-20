//
//  Step.h
//  Raccoon
//
//  Created by Bastien Beurier on 4/19/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipe;

@interface Step : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) Recipe *recipe;

@end
