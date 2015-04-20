//
//  RACTesting.h
//  Raccoon
//
//  Created by Bastien Beurier on 4/16/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RACTesting : NSObject

+ (id)jsonFromFileNamed:(NSString *)fileName;

+ (NSData *)imageDataFromFile:(NSString *)fileName;

@end
