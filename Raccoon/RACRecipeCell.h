//
//  RecipeCell.h
//  Raccoon
//
//  Created by Bastien Beurier on 4/15/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RACRecipeCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *title;

@end
