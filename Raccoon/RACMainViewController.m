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

@interface RACMainViewController ()

@property (weak, nonatomic) IBOutlet UIView *cardsContainer;

@property (strong, nonatomic) RACCardView *topCardView;

@property (strong, nonatomic) RACCardView *bottomCardView;

@property (strong, nonatomic) NSMutableArray *cardsQueue;

@property (nonatomic) float cardPanInitialX;

@property (nonatomic) float cardCenterInitialX;

@end

@implementation RACMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cardsQueue = [[NSMutableArray alloc] initWithCapacity:CARDS_LOADING_BATCH];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardPanned:)];
    [self.cardsContainer addGestureRecognizer:panGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadCards];
}

- (void)loadCards {
    //TODO BB: remove, just for testing
    RACCard *card = [[RACCard alloc] init];
    
    card.imageUrl = @"http://www.kimshealthyeats.com/wp-content/uploads/2013/05/tomato-mozzarella-skewers-02.jpg";
    card.title = @"Tomato Mozzarella Sticks";
    card.healthScore = 87;
    card.duration = 5;
    card.price = 0;
    
    [self.cardsQueue addObject:card];
    
    [self createCardView];
    [self preloadImages];
}

- (void)preloadImages {
    
}

- (void)createCardView {
    self.topCardView = [[RACCardView alloc] initWithCard:[self.cardsQueue objectAtIndex:0] andFrame:self.cardsContainer.bounds];
    
    [self.cardsContainer addSubview:self.topCardView];
    
    self.cardCenterInitialX = self.cardsContainer.center.x;
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
        
        //Bring back card to initial position.
        self.cardsContainer.center = CGPointMake(self.cardCenterInitialX, self.cardsContainer.center.y);
        self.cardsContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
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
            self.cardsContainer.center = CGPointMake(self.cardCenterInitialX - touchPositionOffset, self.cardsContainer.center.y);
            
            //Compute rotation according to touch offset.
            float maxTranslation = (self.view.bounds.size.width + self.cardsContainer.bounds.size.width)/2;
            float rotateRatio = touchPositionOffset/maxTranslation;
        
            //Apply rotation.
            self.cardsContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(rotateRatio * 15));
        }
    }
}


@end
