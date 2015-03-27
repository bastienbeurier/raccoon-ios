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

@interface RACMainViewController ()

@property (weak, nonatomic) IBOutlet UIView *cardsContainer;

@property (strong, nonatomic) RACCardView *topCardView;

@property (strong, nonatomic) RACCardView *bottomCardView;

@property (strong, nonatomic) NSMutableArray *cardsQueue;

@end

@implementation RACMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cardsQueue = [[NSMutableArray alloc] initWithCapacity:CARDS_LOADING_BATCH];
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

@end
