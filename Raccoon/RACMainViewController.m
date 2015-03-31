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
    
    card.imageUrl = @"http://www.kimshealthyeats.com/wp-content/uploads/2013/05/tomato-mozzarella-skewers-02.jpg";
    card.title = @"Tomato Mozzarella Sticks";
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
    card.healthScore = 76;
    card.duration = 10;
    card.price = 0;
    
    self.backCardContainer = [[UIView alloc] initWithFrame:self.cardsContainer.bounds];
    self.backCardView = [[RACCardView alloc] initWithCard:card andFrame:self.cardsContainer.bounds];
    
    [self.backCardContainer addSubview:self.backCardView];
    [self.cardsContainer insertSubview:self.backCardContainer belowSubview:self.frontCardContainer];
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

- (void)cardPanned:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled ||
        recognizer.state == UIGestureRecognizerStateFailed) {
        
        [UIView animateWithDuration:0.3 animations:^{
            //Bring back card to initial position.
            self.frontCardContainer.center = CGPointMake(self.cardCenterInitialX, self.frontCardContainer.center.y);
            self.frontCardContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
        }];
    } else {
        //Touch current position.
        CGPoint touchLocation = [recognizer locationInView:self.view];
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            //Store touch initial position.
            self.cardPanInitialX = touchLocation.x;
        } else {
            //Compute touch offset.
            float touchPositionOffset = self.cardPanInitialX - touchLocation.x;
            
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
