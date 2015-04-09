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
@property (weak, nonatomic) IBOutlet UILabel *firstInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *secondInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *thirdInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *firstInfoView;
@property (weak, nonatomic) IBOutlet UILabel *secondInfoView;
@property (weak, nonatomic) IBOutlet UILabel *thirdInfoView;
@property (weak, nonatomic) IBOutlet UIView *infoViewsContainer;
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

@property (strong, nonatomic) NSArray *steps;

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
                              self.ingredientLabel3];
    
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
    [self.imageView setImageWithURL:[NSURL URLWithString:self.card.imageUrl]];
    
    self.titleView.text = self.card.title;
    
    self.navBar.alpha = 0;
    
    [self setInfoLabels];
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

- (void)setInfoLabels {
    self.firstInfoTitle.text = [NSLocalizedString(@"healthy", nil) uppercaseString];
    self.secondInfoTitle.text = [NSLocalizedString(@"time", nil) uppercaseString];
    self.thirdInfoTitle.text = [NSLocalizedString(@"price", nil) uppercaseString];
    
    self.firstInfoView.text = [NSString stringWithFormat:@"%ld%%", self.card.healthScore];
    self.secondInfoView.text = [NSString stringWithFormat:@"%ld %@", self.card.duration, NSLocalizedString(@"min", nil)];
    
    NSString *priceStr = @"";
    
    for (NSInteger i = 0; i < self.card.price + 1; i++) {
        priceStr = [priceStr stringByAppendingString:@"$"];
    }
    
    self.thirdInfoView.text = priceStr;
    
    //Set separator view height.
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - SEPARATOR_WIDTH)/2,
                                                                     self.infoViewsContainer.frame.size.height - SEPARATOR_HEIGHT,
                                                                     SEPARATOR_WIDTH,
                                                                     SEPARATOR_HEIGHT)];
    
    separatorView.backgroundColor = [UIColor lightGrayColor];
    [self.infoViewsContainer addSubview:separatorView];
}

- (void)setIngredients {
    self.ingredientsCategoryLabel.text = [NSLocalizedString(@"ingredients", nil) uppercaseString];
    
    NSArray *ingredients = @[@"1 pack of cherry tomatoes",
                             @"1 pack of cherry size mozzarella",
                             @"1 pack of fresh basil leaves"];
    
    for (NSInteger i = 0; i < [self.ingredientContainers count]; i++) {
        if (i < [ingredients count]) {
            //Set ingredient text.
            ((UILabel *) [self.ingredientLabels objectAtIndex:i]).text = [ingredients objectAtIndex:i];
        } else {
            //Hide ingredient container.
            ((UIView *) [self.ingredientContainers objectAtIndex:i]).hidden = YES;
        }
    }
    
    //Update the container constraint depending on the number of ingredients.
    self.ingredientsContainerHeightConstraint.constant = [ingredients count] * self.ingredientContainer1.frame.size.height;
    [self.ingredientsContainer setNeedsUpdateConstraints];
    
    //Round corners.
    self.ingredientsContainer.clipsToBounds = YES;
    self.ingredientsContainer.layer.cornerRadius = 5;
}

- (void) setRecipeSteps {
    //Set categroy title.
    self.stepsCategoryLabel.text = [NSLocalizedString(@"steps", nil) uppercaseString];
    
    self.steps = @[@"This is a short step.",
                             @"This is a medium step. This is a medium step. This is a medium step. This is a medium step. This is a medium step. This is a medium step. This is a medium step. This is a medium step. This is a medium step. This is a medium step. This is a medium step. This is a medium step.",
                             @"This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. \n\nThis is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. \n\nThis is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step. This is a long step."];
    
    for (NSInteger i = 0; i < [self.stepContainers count]; i++) {
        if (i < [self.steps count]) {
            //Set nbr text.
            ((UILabel *) [self.stepNbrs objectAtIndex:i]).text = [NSString stringWithFormat:@"%ld/%ld", i + 1, [self.steps count]];
            
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
