//
//  RACCardView.m
//  Raccoon
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACCardView.h"

@interface RACCardView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UITextView *titleView;
@property (strong, nonatomic) UITextView *firstInfoTitleView;
@property (strong, nonatomic) UITextView *secondInfoTitleView;
@property (strong, nonatomic) UITextView *thirdInfoTitleView;
@property (strong, nonatomic) UITextView *firstInfoView;
@property (strong, nonatomic) UITextView *secondInfoView;
@property (strong, nonatomic) UITextView *thirdInfoView;

@end


@implementation RACCardView

- (id)initWithCard:(Card *)card andFrame:(CGRect)frame {
    self = [super init];
    
    if (self) {
        [self initImageView];
        [self initOverlayView];
        [self initTitleView];
        [self initInformationViews];
    }
    
    return self;
}

// ----------------------------------------------------------
#pragma mark Subviews initialization
// ----------------------------------------------------------

- (void)initImageView {
    float size = MIN(self.frame.size.width, self.frame.size.height);
    CGRect frame = CGRectMake(0, 0, size, size);
    self.imageView = [[UIImageView alloc] initWithFrame:frame];
    [self addSubview:self.imageView];
}

- (void)initOverlayView {
    float size = self.imageView.frame.size.height;
    CGRect frame = CGRectMake(0, 0, size, size);
    self.overlayView = [[UIView alloc] initWithFrame:frame];
    [self addSubview:self.overlayView];
}

- (void)initTitleView {
    
}

- (void)initInformationViews {
    
}

@end
