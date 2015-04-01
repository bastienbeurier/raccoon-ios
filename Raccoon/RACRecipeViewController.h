//
//  RACRecipeViewController.h
//  Raccoon
//
//  Created by Bastien Beurier on 4/1/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RACCard.h"

@interface RACRecipeViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) RACCard *card;

@end
