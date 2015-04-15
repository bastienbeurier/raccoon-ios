//
//  Card.h
//  Raccoon
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RACRecipe : NSObject

@property (nonatomic) NSInteger identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSMutableArray *ingredients;
@property (nonatomic, strong) NSMutableArray *steps;

+ (NSArray *)rawsToInstances:(NSArray *)raws;
+ (RACRecipe *)rawToInstance:(NSDictionary *)raw;

@end
