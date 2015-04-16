//
//  RaccoonTests.m
//  RaccoonTests
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RACTesting.h"
#import "RACRecipe.h"
#import "RACUtils.h"

@interface RaccoonTests : XCTestCase

@end

@implementation RaccoonTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testImageCaching {
    UIImage *image = [RACTesting pngFromFile:@"test-image"];
    NSInteger identifier = -1;
    [RACUtils setCachedImage:image forId:identifier];
    
    XCTAssert([RACUtils getCachedImage:identifier], @"Pass");
}

- (void)testRecipesDeserialization {
    id JSON = [RACTesting jsonFromFileNamed:@"recipes"];
    NSDictionary *result = [JSON valueForKeyPath:@"result"];
    NSArray *rawRecipes = [result objectForKey:@"recipes"];
    NSArray *recipes = [RACRecipe rawsToInstances:rawRecipes];
    
    XCTAssert([recipes count] == 8, @"Pass");
}

- (void)testRecipesDeserializationPerformance {
    [self measureBlock:^{
        id JSON = [RACTesting jsonFromFileNamed:@"recipes"];
        
        NSDictionary *result = [JSON valueForKeyPath:@"result"];
        
        NSArray *rawRecipes = [result objectForKey:@"recipes"];
        
        [RACRecipe rawsToInstances:rawRecipes];
    }];
}

@end
