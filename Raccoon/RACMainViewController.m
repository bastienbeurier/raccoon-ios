//
//  ViewController.m
//  Raccoon
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACMainViewController.h"
#import "RACRecipe.h"
#import "RACCardView.h"
#import "RACRecipeViewController.h"
#import "RACApi.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "RACUtils.h"

#define CARDS_LOADING_BATCH 10
#define DEGREES_TO_RADIANS(degrees)  ((3.1416 * degrees)/ 180)

#define DECORATION_CARD_CORNER_RADIUS 5.0
#define DECORATION_CARD_BORDER_WIDTH 0.5

@interface RACMainViewController ()

@property (weak, nonatomic) IBOutlet UIView *cardsContainer;
@property (weak, nonatomic) IBOutlet UIView *firstDecorationCard;
@property (weak, nonatomic) IBOutlet UIView *secondDecorationCard;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (strong, nonatomic) UIView *frontCardContainer;
@property (strong, nonatomic) RACCardView *frontCardView;

@property (strong, nonatomic) UIView *backCardContainer;
@property (strong, nonatomic) RACCardView *backCardView;

//Keep track of initial positions for panning gesture.
@property (nonatomic) float cardPanInitialX;
@property (nonatomic) float cardContainerInitialX;

@property (nonatomic) NSInteger recipeOffset;

@property (nonatomic, strong) NSMutableArray *recipes;

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

@property (nonatomic) BOOL fetchingRecipes;
@property (nonatomic) BOOL noMoreRecipesToFetch;

@end

@implementation RACMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set card pan gesture recognizer.
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardPanned:)];
    [self.cardsContainer addGestureRecognizer:panGestureRecognizer];
    
    //Set card tap gesture recognizer.
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardPressed:)];
    [self.cardsContainer addGestureRecognizer:tapGestureRecognizer];
    
    //Set first decoration card border.
    self.firstDecorationCard.layer.cornerRadius = DECORATION_CARD_CORNER_RADIUS;
    self.firstDecorationCard.layer.borderWidth = DECORATION_CARD_BORDER_WIDTH;
    self.firstDecorationCard.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //Set second decoration card border.
    self.secondDecorationCard.layer.cornerRadius = DECORATION_CARD_CORNER_RADIUS;
    self.secondDecorationCard.layer.borderWidth = DECORATION_CARD_BORDER_WIDTH;
    self.secondDecorationCard.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //Load recipes cards.
    [self initializeCards];
    [self loadCards];
}

- (void)initializeCards {
    //No recipe loaded yet yet.
    self.recipes = [NSMutableArray new];
    self.recipeOffset = 0;
    self.fetchingRecipes = NO;
    self.noMoreRecipesToFetch = NO;
    
    //Init the queue for downloading images.
    if (self.imagesQueue) {
        [self.imagesQueue cancelAllOperations];
    }
    self.imagesQueue = [[NSOperationQueue alloc] init];
    self.imagesQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    
    //Hide decoration cards.
    self.firstDecorationCard.hidden = YES;
    self.secondDecorationCard.hidden = YES;
    
    //Animate loading spinner.
    self.loadingSpinner.hidden = NO;
    [self.loadingSpinner startAnimating];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    
    if ([segueName isEqualToString: @"Recipe Segue"]) {
        ((RACRecipeViewController *) [segue destinationViewController]).recipe = self.frontCardView.recipe;
    }
}

- (void)loadCards {
    if (self.fetchingRecipes) {
        return;
    }
    
    self.fetchingRecipes = YES;
    
    [RACApi getRecipes:CARDS_LOADING_BATCH orderBy:@"created_at" offset:0 success:^(NSArray *recipes) {
        if ([recipes count] < CARDS_LOADING_BATCH) {
            self.noMoreRecipesToFetch = YES;
        }
        
        //TODO BB: check case where 0, 1 or 2 recipes fetched (first fetch or later fetch).
        
        //Add loaded recipes to the array of recipes.
        [self.recipes addObjectsFromArray:recipes];
        
        //Load the two first images.
        [self.imagesQueue addOperationWithBlock: ^{
            for (NSInteger i = 0; i < MIN([self.recipes count], 2); i++) {
                RACRecipe *recipe = [self.recipes objectAtIndex:i];
                NSURL *url = [NSURL URLWithString:recipe.imageUrl];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                //Check if not already cached.
                if (![[UIImageView sharedImageCache] cachedImageForRequest:request]) {
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                    [[UIImageView sharedImageCache] cacheImage:image forRequest:request];
                }
            }
            
            //Back on the UI thread.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //Remove loading spinner.
                [self.loadingSpinner stopAnimating];
                self.loadingSpinner.hidden = YES;
                
                //Create front and back card.
                [self createFrontCardView];
                [self createBackCardView];
                
                //Keep track of initial card position (for panning gesture).
                self.cardContainerInitialX = self.frontCardContainer.center.x;
                
                //Show decoration cards.
                self.firstDecorationCard.hidden = NO;
                self.secondDecorationCard.hidden = NO;
                
                //TODO BB: only load new recipes.
                [self preloadImages];
            }];
        }];
    } failure:^{
        //Connection problem, show alert dialog.
        [RACUtils showMessage:NSLocalizedString(@"no_connection_message", nil)
                forController:self
                    withTitle:NSLocalizedString(@"no_connection_title", nil)
                       action:NSLocalizedString(@"OK", nil)
                   completion:^{
                       [self loadCards];
                   }];
    }];
}

- (void)preloadImages {
    for (RACRecipe *recipe in self.recipes) {
        [self.imagesQueue addOperationWithBlock: ^{
            NSURL *url = [NSURL URLWithString:recipe.imageUrl];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            //Check if not already cached.
            if (![[UIImageView sharedImageCache] cachedImageForRequest:request]) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                [[UIImageView sharedImageCache] cacheImage:image forRequest:request];
            }
        }];
    }
}

- (void)createFrontCardView {
    if ([self.recipes count] == 0) {
        return;
    }
    
    RACRecipe *recipe = [self.recipes firstObject];
    [self.recipes removeObjectAtIndex:0];
    
    self.frontCardContainer = [[UIView alloc] initWithFrame:self.cardsContainer.bounds];
    self.frontCardView = [[RACCardView alloc] initWithRecipe:recipe andFrame:self.cardsContainer.bounds];
    
    [self.frontCardContainer addSubview:self.frontCardView];
    [self.cardsContainer addSubview:self.frontCardContainer];
}

- (void)createBackCardView {
    if ([self.recipes count] == 0) {
        self.backCardContainer = nil;
        self.backCardView = nil;
        return;
    }
    
    RACRecipe *recipe = [self.recipes firstObject];
    [self.recipes removeObjectAtIndex:0];
    
    self.backCardContainer = [[UIView alloc] initWithFrame:self.cardsContainer.bounds];
    self.backCardView = [[RACCardView alloc] initWithRecipe:recipe andFrame:self.cardsContainer.bounds];
    
    [self.backCardContainer addSubview:self.backCardView];
    [self.cardsContainer insertSubview:self.backCardContainer belowSubview:self.frontCardContainer];
}

- (void)bringBackCardToFrontAndCreateNewBackCard {
    //No more card to display.
    if (!self.backCardContainer) {
        if (self.noMoreRecipesToFetch) {
            //Show dialog to restart the card deck.
            [RACUtils showMessage:NSLocalizedString(@"no_more_recipe_message", nil)
                    forController:self
                        withTitle:NSLocalizedString(@"no_more_recipe_title", nil)
                           action:NSLocalizedString(@"OK", nil)
                       completion:^{
                           [self initializeCards];
                           [self loadCards];
                       }];
        } else {
            //Show loading UI.
        }
    }
    
    //Back card goes to front.
    self.frontCardContainer = self.backCardContainer;
    self.frontCardView = self.backCardView;
    
    //Load new back card.
    [self createBackCardView];
}

- (void)cardPressed:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"Recipe Segue" sender:nil];
}

- (void)cardPanned:(UIPanGestureRecognizer *)recognizer {
    //Touch current position.
    CGPoint touchLocation = [recognizer locationInView:self.view];
    
    //Compute touch offset.
    float touchPositionOffset = self.cardPanInitialX - touchLocation.x;
    
    //Card is dropped.
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled ||
        recognizer.state == UIGestureRecognizerStateFailed) {
        
        //Card is panned enough to be dismissed.
        if (ABS(touchPositionOffset) > self.cardsContainer.frame.size.width / 2) {
            [self dismissCard:touchPositionOffset];
        //Card is not panned enough to be dismissed.
        } else {
            [self restoreCardPosition];
        }
    //Card is panned.
    } else {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            //Store touch initial position.
            self.cardPanInitialX = touchLocation.x;
        } else {
            //Move card according to touch offset.
            self.frontCardContainer.center = CGPointMake(self.cardContainerInitialX - touchPositionOffset, self.frontCardContainer.center.y);
            
            //Compute rotation according to touch offset.
            float maxTranslation = (self.view.bounds.size.width + self.frontCardContainer.bounds.size.width)/2;
            float rotateRatio = touchPositionOffset/maxTranslation;
        
            //Apply rotation.
            self.frontCardContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(rotateRatio * 15));
            
            //Hide decoration cards if it's the last card.
            if (!self.backCardContainer) {
                //Hide decoration cards.
                self.firstDecorationCard.hidden = YES;
                self.secondDecorationCard.hidden = YES;
            }
        }
    }
}

- (void)dismissCard:(NSInteger)offset
{
    [UIView animateWithDuration:0.2 animations:^{
        float offScreenPosition = self.view.bounds.size.width + self.frontCardContainer.bounds.size.width;
        
        //Move card out of screen.
        if (offset > 0) {
            self.frontCardContainer.center = CGPointMake(self.cardContainerInitialX - offScreenPosition, self.frontCardContainer.center.y);
        } else {
            self.frontCardContainer.center = CGPointMake(self.cardContainerInitialX + offScreenPosition, self.frontCardContainer.center.y);
        }
        
        //Apply rotation.
        self.frontCardContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(15));
    } completion:^(BOOL finished) {
        //Dismiss card
        [self.frontCardContainer removeFromSuperview];
        [self.frontCardView removeFromSuperview];
        
        //Update front and back cards
        [self bringBackCardToFrontAndCreateNewBackCard];
    }];
}

- (void)restoreCardPosition
{
    [UIView animateWithDuration:0.3 animations:^{
        //Bring back card to initial position.
        self.frontCardContainer.center = CGPointMake(self.cardContainerInitialX, self.frontCardContainer.center.y);
        self.frontCardContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
    }];
}


@end
