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

@property (strong, nonatomic) NSMutableArray *cardsQueue;

@property (nonatomic) float cardPanInitialX;

@property (nonatomic) BOOL cardsInitiallyLoaded;

@property (nonatomic) NSInteger cardsOffset;

@property (nonatomic, strong) NSMutableArray *recipes;

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

@end

@implementation RACMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Cards are not loaded yet.
    self.cardsInitiallyLoaded = NO;
    self.cardsOffset = 0;
    self.recipes = [NSMutableArray new];
    
    //Init the array of loaded cards.
    self.cardsQueue = [[NSMutableArray alloc] initWithCapacity:CARDS_LOADING_BATCH];
    
    //Init the queue for downloading images.
    self.imagesQueue = [[NSOperationQueue alloc] init];
    self.imagesQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    
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
    self.firstDecorationCard.hidden = YES;
    
    //Set second decoration card border.
    self.secondDecorationCard.layer.cornerRadius = DECORATION_CARD_CORNER_RADIUS;
    self.secondDecorationCard.layer.borderWidth = DECORATION_CARD_BORDER_WIDTH;
    self.secondDecorationCard.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.secondDecorationCard.hidden = YES;
    
    //Animate loading spinner.
    [self.loadingSpinner startAnimating];
    
    //Load recipes
    [self loadCards];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    
    if ([segueName isEqualToString: @"Recipe Segue"]) {
        ((RACRecipeViewController *) [segue destinationViewController]).recipe = self.frontCardView.recipe;
    }
}

- (void)loadCards {
    [RACApi getRecipes:CARDS_LOADING_BATCH orderBy:@"created_at" offset:0 success:^(NSArray *recipes) {
        //Add loaded recipes to the array of recipes.
        [self.recipes addObjectsFromArray:recipes];
        
        //Load the two first images.
        [self.imagesQueue addOperationWithBlock: ^{
            for (NSInteger i = 0; i < MIN([self.recipes count], 2); i++) {
                RACRecipe *recipe = [self.recipes objectAtIndex:i];
                NSURL *url = [NSURL URLWithString:recipe.imageUrl];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [[UIImageView sharedImageCache] cacheImage:image forRequest:request];
            }
            
            //Back on the UI thread.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //Remove loading spinner.
                [self.loadingSpinner stopAnimating];
                self.loadingSpinner.hidden = YES;
                
                //Create front and back card.
                [self createFrontCardView];
                [self createBackCardView];
                
                //Show decoration cards.
                self.firstDecorationCard.hidden = NO;
                self.secondDecorationCard.hidden = NO;
                
                [self preloadImages];
            }];
        }];
    } failure:^{
        //Connection problem, show alert dialog.
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"no_connection_title", nil)
                                              message:NSLocalizedString(@"no_connection_message", nil)
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {[self loadCards];}];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)preloadImages {
    for (RACRecipe *recipe in self.recipes) {
        [self.imagesQueue addOperationWithBlock: ^{
            NSURL *url = [NSURL URLWithString:recipe.imageUrl];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [[UIImageView sharedImageCache] cacheImage:image forRequest:request];
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
    self.frontCardContainer = self.backCardContainer;
    self.frontCardView = self.backCardView;
    
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
            self.frontCardContainer.center = CGPointMake(self.backCardContainer.center.x - touchPositionOffset, self.frontCardContainer.center.y);
            
            //Compute rotation according to touch offset.
            float maxTranslation = (self.view.bounds.size.width + self.frontCardContainer.bounds.size.width)/2;
            float rotateRatio = touchPositionOffset/maxTranslation;
        
            //Apply rotation.
            self.frontCardContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(rotateRatio * 15));
        }
    }
}

- (void)dismissCard:(NSInteger)offset
{
    [UIView animateWithDuration:0.2 animations:^{
        float offScreenPosition = self.view.bounds.size.width + self.frontCardContainer.bounds.size.width;
        
        //Move card out of screen.
        if (offset > 0) {
            self.frontCardContainer.center = CGPointMake(self.backCardContainer.center.x - offScreenPosition, self.frontCardContainer.center.y);
        } else {
            self.frontCardContainer.center = CGPointMake(self.backCardContainer.center.x + offScreenPosition, self.frontCardContainer.center.y);
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
        self.frontCardContainer.center = CGPointMake(self.backCardContainer.center.x, self.frontCardContainer.center.y);
        self.frontCardContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
    }];
}


@end
