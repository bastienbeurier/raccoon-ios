//
//  RACCardView.m
//  Raccoon
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACCardView.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 5.0
#define BORDER_WIDTH 0.5

@interface RACCardView ()

//Card object.
@property (strong, nonatomic) RACCard *card;

//Subviews.
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *firstInfoView;
@property (weak, nonatomic) IBOutlet UILabel *secondInfoView;
@property (weak, nonatomic) IBOutlet UILabel *thirdInfoView;
@property (weak, nonatomic) IBOutlet UILabel *firstInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *secondInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *thirdInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *ingredientsView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingSpinner;
@property (weak, nonatomic) IBOutlet UIView *titleBackgroundView;

@end


@implementation RACCardView

// ----------------------------------------------------------
#pragma mark Overrides
// ----------------------------------------------------------

- (instancetype)initWithCard:(RACCard *)card andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.card = card;
        
        //Init view from nib file.
        [[NSBundle mainBundle] loadNibNamed:@"RACCardView" owner:self options:nil];
        self.view.frame = self.bounds;
        [self addSubview:self.view];
        
        //Add borders and round corners to the view.
        self.layer.cornerRadius = CORNER_RADIUS;
        self.clipsToBounds = YES;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = BORDER_WIDTH;
        
        //Set gradient.
        [self setTitleBackgroundGradient];
        
        //Fill card information.
        [self loadImage];
        [self setInfoLabels];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:self.view];
}

// ----------------------------------------------------------
#pragma mark Other methods
// ----------------------------------------------------------

- (void)loadImage {
    self.titleBackgroundView.hidden = YES;
    [self.imageLoadingSpinner startAnimating];
    
    //Load image.
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.card.imageUrl]]
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       [self.imageLoadingSpinner stopAnimating];
                                       self.imageLoadingSpinner.hidden = YES;
                                       self.imageView.image = image;
                                       self.titleBackgroundView.hidden = NO;
                                       [self setOverlayLabels];
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *errir) {
                                       //
                                   }];
}

- (void)setTitleBackgroundGradient {
    //Vertical black to clear gradient.
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect gradientFrame = self.titleBackgroundView.bounds;
    gradient.frame = gradientFrame;
    UIColor *startColor = [UIColor clearColor];
    UIColor *endColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
    [self.titleBackgroundView.layer insertSublayer:gradient atIndex:0];
}

- (void)setOverlayLabels {
    self.titleView.text = self.card.title;
    self.ingredientsView.text = self.card.ingredients;
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
}

@end
