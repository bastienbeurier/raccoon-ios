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

#define OVERLAY_GRADIENT_HEIGHT 70.0
#define TITLE_LABEL_HEIGHT 40.0

@interface RACCardView ()

//Underlying model.
@property (strong, nonatomic) RACCard *card;

//Subviews.

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *firstInfoView;
@property (weak, nonatomic) IBOutlet UILabel *secondInfoView;
@property (weak, nonatomic) IBOutlet UILabel *thirdInfoView;


@end


@implementation RACCardView

- (id)initWithCard:(RACCard *)card andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"RACCardView" owner:self options:nil];
        self.view.frame = self.bounds;
        [self addSubview:self.view];
        
        self.layer.cornerRadius = 5.0;
        self.clipsToBounds = YES;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 0.5;
        
        self.card = card;
        
        [self loadImage];
        [self showOverlayGradient];
        [self setLabels];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:self.view];
}

// ----------------------------------------------------------
#pragma mark Subviews initialization
// ----------------------------------------------------------

- (void)loadImage {
    //TODO BB: loading sign while image is loading.
    
    [self.imageView setImageWithURL:[NSURL URLWithString:self.card.imageUrl]];
}

- (void)showOverlayGradient {
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    CGRect gradientFrame = CGRectMake(0, 0, self.overlayView.frame.size.width, OVERLAY_GRADIENT_HEIGHT);
    topGradient.frame = gradientFrame;
    UIColor *startColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    UIColor *endColor = [UIColor clearColor];
    topGradient.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
    [self.overlayView.layer insertSublayer:topGradient atIndex:0];
}

- (void)setLabels {
    self.titleView.text = self.card.title;
    
    self.firstInfoView.text = [NSString stringWithFormat:@"%ld%%", self.card.healthScore];
    self.secondInfoView.text = [NSString stringWithFormat:@"%ld%@", self.card.duration, NSLocalizedString(@"mins", nil)];
    
    NSString *priceStr = @"";
    
    for (NSInteger i = 0; i < self.card.price + 1; i++) {
        priceStr = [priceStr stringByAppendingString:@"$"];
    }
    
    self.thirdInfoView.text = priceStr;
}

@end
