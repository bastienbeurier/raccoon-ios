//
//  Card.h
//  Raccoon
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RACCard : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *ingredients;
@property (nonatomic) NSInteger healthScore;
@property (nonatomic) NSInteger duration;
@property (nonatomic) NSInteger price;

@end
