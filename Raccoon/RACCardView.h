//
//  RACCardView.h
//  Raccoon
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RACRecipe.h"

@interface RACCardView : UIView

//Card object.
@property (strong, nonatomic) RACRecipe *recipe;

- (id)initWithRecipe:(RACRecipe *)recipe andFrame:(CGRect)frame;

@end
