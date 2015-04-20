//
//  RACRecipeViewController.m
//  Raccoon
//
//  Created by Bastien Beurier on 4/1/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACRecipeViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "RACGraphics.h"
#import "RACUtils.h"
#import "Ingredient.h"
#import "Step.h"

#define IMAGE_HEIGHT 150
#define SEPARATOR_HEIGHT 0.5
#define SEPARATOR_WIDTH 140
#define RECIPE_STEP_TOP_MARGIN 15

@interface RACRecipeViewController ()


@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (strong, nonatomic) UIView *imageTitleContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ingredientsContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *ingredientsCategoryLabel;
@property (weak, nonatomic) IBOutlet UIView *ingredientsContainer;
@property (weak, nonatomic) IBOutlet UIView *ingredientContainer1;
@property (weak, nonatomic) IBOutlet UIView *ingredientContainer2;
@property (weak, nonatomic) IBOutlet UIView *ingredientContainer3;
@property (weak, nonatomic) IBOutlet UIView *ingredientContainer4;
@property (weak, nonatomic) IBOutlet UIView *ingredientContainer5;
@property (weak, nonatomic) IBOutlet UIView *ingredientContainer6;
@property (weak, nonatomic) IBOutlet UIView *ingredientContainer7;
@property (weak, nonatomic) IBOutlet UIView *ingredientContainer8;
@property (weak, nonatomic) IBOutlet UIView *ingredientContainer9;
@property (weak, nonatomic) IBOutlet UIView *ingredientContainer10;
@property (weak, nonatomic) IBOutlet UILabel *ingredientLabel1;
@property (weak, nonatomic) IBOutlet UILabel *ingredientLabel2;
@property (weak, nonatomic) IBOutlet UILabel *ingredientLabel3;
@property (weak, nonatomic) IBOutlet UILabel *ingredientLabel4;
@property (weak, nonatomic) IBOutlet UILabel *ingredientLabel5;
@property (weak, nonatomic) IBOutlet UILabel *ingredientLabel6;
@property (weak, nonatomic) IBOutlet UILabel *ingredientLabel7;
@property (weak, nonatomic) IBOutlet UILabel *ingredientLabel8;
@property (weak, nonatomic) IBOutlet UILabel *ingredientLabel9;
@property (weak, nonatomic) IBOutlet UILabel *ingredientLabel10;
@property (strong, nonatomic) NSArray *ingredientContainers;
@property (strong, nonatomic) NSArray *ingredientLabels;
@property (weak, nonatomic) IBOutlet UILabel *stepsCategoryLabel;
@property (weak, nonatomic) IBOutlet UIView *stepContainer1;
@property (weak, nonatomic) IBOutlet UIView *stepContainer2;
@property (weak, nonatomic) IBOutlet UIView *stepContainer3;
@property (weak, nonatomic) IBOutlet UIView *stepContainer4;
@property (weak, nonatomic) IBOutlet UIView *stepContainer5;
@property (weak, nonatomic) IBOutlet UIView *stepContainer6;
@property (weak, nonatomic) IBOutlet UILabel *stepNbr1;
@property (weak, nonatomic) IBOutlet UILabel *stepNbr2;
@property (weak, nonatomic) IBOutlet UILabel *stepNbr3;
@property (weak, nonatomic) IBOutlet UILabel *stepNbr4;
@property (weak, nonatomic) IBOutlet UILabel *stepNbr5;
@property (weak, nonatomic) IBOutlet UILabel *stepNbr6;
@property (weak, nonatomic) IBOutlet UITextView *stepDesc1;
@property (weak, nonatomic) IBOutlet UITextView *stepDesc2;
@property (weak, nonatomic) IBOutlet UITextView *stepDesc3;
@property (weak, nonatomic) IBOutlet UITextView *stepDesc4;
@property (weak, nonatomic) IBOutlet UITextView *stepDesc5;
@property (weak, nonatomic) IBOutlet UITextView *stepDesc6;
@property (strong, nonatomic) NSArray *stepContainers;
@property (strong, nonatomic) NSArray *stepNbrs;
@property (strong, nonatomic) NSArray *stepDescs;
@property (strong, nonatomic) NSMutableArray *ingredients;
@property (strong, nonatomic) NSMutableArray *steps;

@end

@implementation RACRecipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set scroll view delegate.
    self.scrollView.delegate = self;
    
    //Store containers and labels in arrays for simplicity.
    self.ingredientContainers = @[self.ingredientContainer1,
                                  self.ingredientContainer2,
                                  self.ingredientContainer3,
                                  self.ingredientContainer4,
                                  self.ingredientContainer5,
                                  self.ingredientContainer6,
                                  self.ingredientContainer7,
                                  self.ingredientContainer8,
                                  self.ingredientContainer9,
                                  self.ingredientContainer10];
    
    self.ingredientLabels = @[self.ingredientLabel1,
                              self.ingredientLabel2,
                              self.ingredientLabel3,
                              self.ingredientLabel4,
                              self.ingredientLabel5,
                              self.ingredientLabel6,
                              self.ingredientLabel7,
                              self.ingredientLabel8,
                              self.ingredientLabel9,
                              self.ingredientLabel10];
    
    self.stepContainers = @[self.stepContainer1,
                            self.stepContainer2,
                            self.stepContainer3,
                            self.stepContainer4,
                            self.stepContainer5,
                            self.stepContainer6];
    
    self.stepNbrs = @[self.stepNbr1,
                      self.stepNbr2,
                      self.stepNbr3,
                      self.stepNbr4,
                      self.stepNbr5,
                      self.stepNbr6];
    
    self.stepDescs = @[self.stepDesc1,
                       self.stepDesc2,
                       self.stepDesc3,
                       self.stepDesc4,
                       self.stepDesc5,
                       self.stepDesc6];
    
    //Set scroll view size based on image width.
    self.imageWidthConstraint.constant = self.view.frame.size.width;
    [self.scrollView setNeedsUpdateConstraints];
    
    //Set recipe image.
    UIImage *image = [RACUtils getCachedImage:self.recipe.identifier];
    
    if (image) {
        //Image in cache. Show with animation.
        [UIView transitionWithView:self.imageView
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.imageView.image = image;
                        } completion:NULL];
    } else {
        //download image
        [self.imageView setImageWithURL:[NSURL URLWithString:self.recipe.imageUrl]];
    }

    self.titleView.text = [self.recipe.title uppercaseString];
    
    self.navBar.alpha = 0;
    
    self.ingredients = [NSMutableArray new];
    for (Ingredient *ingredient in self.recipe.ingredients) {
        [self.ingredients addObject:ingredient.desc];
    }
    
    self.steps = [NSMutableArray new];
    for (Step *step in self.recipe.steps) {
        [self.steps addObject:step.desc];
    }
    
    [self setIngredients];
    [self setRecipeSteps];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setIngredients {
    self.ingredientsCategoryLabel.text = [NSLocalizedString(@"ingredients", nil) uppercaseString];
    
    for (NSInteger i = 0; i < [self.ingredientContainers count]; i++) {
        if (i < [self.recipe.ingredients count]) {
            //Set ingredient text.
            ((UILabel *) [self.ingredientLabels objectAtIndex:i]).text = [self.ingredients objectAtIndex:i];
        } else {
            //Hide ingredient container.
            ((UIView *) [self.ingredientContainers objectAtIndex:i]).hidden = YES;
        }
    }
    
    //Update the container constraint depending on the number of ingredients.
    self.ingredientsContainerHeightConstraint.constant = [self.recipe.ingredients count] * self.ingredientContainer1.frame.size.height;
    [self.ingredientsContainer setNeedsUpdateConstraints];
    
    //Round corners.
    self.ingredientsContainer.clipsToBounds = YES;
    self.ingredientsContainer.layer.cornerRadius = 5;
}

- (void) setRecipeSteps {
    //Set categroy title.
    self.stepsCategoryLabel.text = [NSLocalizedString(@"steps", nil) uppercaseString];
    
    for (NSInteger i = 0; i < [self.stepContainers count]; i++) {
        if (i < [self.recipe.steps count]) {
            //Set nbr text.
            ((UILabel *) [self.stepNbrs objectAtIndex:i]).text = [NSString stringWithFormat:@"%ld/%ld", i + 1, [self.recipe.steps count]];
            
            //Set description text.
            ((UITextView *) [self.stepDescs objectAtIndex:i]).text = [self.steps objectAtIndex:i];
            
            //Corder radius
            ((UIView *) [self.stepContainers objectAtIndex:i]).clipsToBounds = YES;
            ((UIView *) [self.stepContainers objectAtIndex:i]).layer.cornerRadius = 5;
        } else {
            //Hide step container.
            UIView *containerView = (UIView *) [self.stepContainers objectAtIndex:i];
            containerView.hidden = YES;
            
            //Update contraint.
            [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:0]];
            
            [containerView setNeedsUpdateConstraints];
        }
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float yOffset = scrollView.contentOffset.y;
    
    //Nav bar fades while scrolling.
    self.navBar.alpha = MAX(0, yOffset / IMAGE_HEIGHT);
    
    //Zoom effect on image when scroll view top is reached.
    if (yOffset < 0) {
        self.imageView.frame = CGRectMake(0, yOffset, self.imageView.frame.size.width, IMAGE_HEIGHT - yOffset);
    }
}


@end
