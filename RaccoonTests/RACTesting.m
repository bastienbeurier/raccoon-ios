//
//  RACTesting.m
//  Raccoon
//
//  Created by Bastien Beurier on 4/16/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACTesting.h"

@implementation RACTesting

+ (id)jsonFromFileNamed:(NSString *)fileName
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *resource = [bundle pathForResource:fileName ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:resource];
    
    NSError *error = nil;
    NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    return json;
}

+ (UIImage *)pngFromFile:(NSString *)fileName
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *resource = [bundle pathForResource:fileName ofType:@"png"];
    
    NSData *imageData = [NSData dataWithContentsOfFile:resource];
    
    return [UIImage imageWithData:imageData];
}

@end
