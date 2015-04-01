//
//  RACCardView.h
//  Raccoon
//
//  Created by Bastien Beurier on 3/26/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RACCard.h"

@interface RACCardView : UIView

//Card object.
@property (strong, nonatomic) RACCard *card;

- (id)initWithCard:(RACCard *)card andFrame:(CGRect)frame;

@end
