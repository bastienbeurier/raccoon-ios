//
//  ViewController.m
//  Raccoon
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACMainViewController.h"
#import "RACCard.h"
#import "RACCardView.h"
#import "RACRecipeViewController.h"

#define CARDS_LOADING_BATCH 10
#define   DEGREES_TO_RADIANS(degrees)  ((3.1416 * degrees)/ 180)

#define DECORATION_CARD_CORNER_RADIUS 5.0
#define DECORATION_CARD_BORDER_WIDTH 0.5

@interface RACMainViewController ()

@property (weak, nonatomic) IBOutlet UIView *cardsContainer;
@property (weak, nonatomic) IBOutlet UIView *firstDecorationCard;
@property (weak, nonatomic) IBOutlet UIView *secondDecorationCard;

@property (strong, nonatomic) UIView *frontCardContainer;
@property (strong, nonatomic) RACCardView *frontCardView;

@property (strong, nonatomic) UIView *backCardContainer;
@property (strong, nonatomic) RACCardView *backCardView;

@property (strong, nonatomic) NSMutableArray *cardsQueue;

@property (nonatomic) float cardPanInitialX;

@property (nonatomic) float cardCenterInitialX;

@end

@implementation RACMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Init the queue of loaded cards.
    self.cardsQueue = [[NSMutableArray alloc] initWithCapacity:CARDS_LOADING_BATCH];
    
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadCards];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    
    if ([segueName isEqualToString: @"Recipe Segue"]) {
        ((RACRecipeViewController *) [segue destinationViewController]).card = self.frontCardView.card;
    }
}

- (void)loadCards {
    //BB TODO: load cards and add them to queue.
    
    [self createFrontCardView];
    [self createBackCardView];
    [self preloadImages];
}

- (void)preloadImages {
    
}

- (void)createFrontCardView {
    //TODO BB: remove, just for testing
    RACCard *card = [[RACCard alloc] init];
    
    card.imageUrl = @"http://afoodcentriclife.com/wp-content/uploads/2014/06/Waimea-Salad1.jpg";
    card.title = @"Tomato Mozzarella Sticks";
    card.ingredients = @"tomato, mozzarella, basil, balsamic vinegar, olive oil";
    card.healthScore = 87;
    card.duration = 5;
    card.price = 0;
    
    self.frontCardContainer = [[UIView alloc] initWithFrame:self.cardsContainer.bounds];
    self.frontCardView = [[RACCardView alloc] initWithCard:card andFrame:self.cardsContainer.bounds];
    
    [self.frontCardContainer addSubview:self.frontCardView];
    [self.cardsContainer addSubview:self.frontCardContainer];
    
    self.cardCenterInitialX = self.frontCardContainer.center.x;
}

- (void)createBackCardView {
    //TODO BB: remove, just for testing
    RACCard *card = [[RACCard alloc] init];
    
    card.imageUrl = @"http://afoodcentriclife.com/wp-content/uploads/2014/06/Waimea-Salad1.jpg";
    card.title = @"Hawaiian Salad";
    card.ingredients = @"salad, tomato, feta cheese, apricot";
    card.healthScore = 76;
    card.duration = 10;
    card.price = 0;
    
    self.backCardContainer = [[UIView alloc] initWithFrame:self.cardsContainer.bounds];
    self.backCardView = [[RACCardView alloc] initWithCard:card andFrame:self.cardsContainer.bounds];
    
    [self.backCardContainer addSubview:self.backCardView];
    [self.cardsContainer insertSubview:self.backCardContainer belowSubview:self.frontCardContainer];
}

- (void)bringBackCardToFrontAndCreateNewBackCard {
    self.frontCardContainer = self.backCardContainer;
    self.frontCardView = self.backCardView;
    
    [self createBackCardView];
}

- (void)cardMoved {
    
}

- (void)cardPressed {
    
}

- (void)cardDismissPressed {
    
}

- (void)animateDismissCard {
    
}

- (void)cardDismissed {
    
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
            [UIView animateWithDuration:0.2 animations:^{
                float offScreenPosition = self.view.bounds.size.width + self.frontCardContainer.bounds.size.width;
                
                //Move card out of screen.
                if (touchPositionOffset > 0) {
                    self.frontCardContainer.center = CGPointMake(self.cardCenterInitialX - offScreenPosition, self.frontCardContainer.center.y);
                } else {
                    self.frontCardContainer.center = CGPointMake(self.cardCenterInitialX + offScreenPosition, self.frontCardContainer.center.y);
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
        //Card is not panned enough to be dismissed.
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                //Bring back card to initial position.
                self.frontCardContainer.center = CGPointMake(self.cardCenterInitialX, self.frontCardContainer.center.y);
                self.frontCardContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
            }];
        }
    //Card is panned.
    } else {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            //Store touch initial position.
            self.cardPanInitialX = touchLocation.x;
        } else {
            //Move card according to touch offset.
            self.frontCardContainer.center = CGPointMake(self.cardCenterInitialX - touchPositionOffset, self.frontCardContainer.center.y);
            
            //Compute rotation according to touch offset.
            float maxTranslation = (self.view.bounds.size.width + self.frontCardContainer.bounds.size.width)/2;
            float rotateRatio = touchPositionOffset/maxTranslation;
        
            //Apply rotation.
            self.frontCardContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(rotateRatio * 15));
        }
    }
}


@end
