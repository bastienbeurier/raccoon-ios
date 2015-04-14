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

//Subviews.
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingSpinner;
@property (weak, nonatomic) IBOutlet UITextView *titleView;

@end


@implementation RACCardView

// ----------------------------------------------------------
#pragma mark Overrides
// ----------------------------------------------------------

- (instancetype)initWithRecipe:(RACRecipe *)recipe andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.recipe = recipe;
        
        //Init view from nib file.
        [[NSBundle mainBundle] loadNibNamed:@"RACCardView" owner:self options:nil];
        self.view.frame = self.bounds;
        [self addSubview:self.view];
        
        //Add borders and round corners to the view.
        self.layer.cornerRadius = CORNER_RADIUS;
        self.clipsToBounds = YES;
        
        //Fill card information.
        [self loadImage];
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
    self.overlayView.hidden = YES;
    [self.imageLoadingSpinner startAnimating];
    
    //Load image.
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.recipe.imageUrl]]
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       [self.imageLoadingSpinner stopAnimating];
                                       self.imageLoadingSpinner.hidden = YES;
                                       self.imageView.image = image;
                                       [self setOverlayLabels];
                                       [self setOverlayGradient];
                                       self.overlayView.hidden = NO;
                                   } failure:nil];
}

- (void)setOverlayGradient {
    //Vertical black to clear gradient.
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect gradientFrame = self.overlayView.bounds;
    gradient.frame = gradientFrame;
    UIColor *startColor = [UIColor clearColor];
    UIColor *endColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
    [self.overlayView.layer insertSublayer:gradient atIndex:0];
}

- (void)setOverlayLabels {
    self.titleView.text = [self.recipe.title uppercaseString];
}

@end
