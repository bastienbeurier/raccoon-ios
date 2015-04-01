//
//  RACRecipeViewController.m
//  Raccoon
//
//  Created by Bastien Beurier on 4/1/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACRecipeViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "RACGraphics.h"

#define IMAGE_HEIGHT 150
#define IMAGE_TITLE_CONTAINER_HEIGHT 50
#define INFOS_CONTAINER_HEIGHT 70
#define INFO_LABEL_HEIGHT 28
#define INFO_LABEL_TOP_MARGIN 15
#define INFO_TITLE_LABEL_HEIGHT 12
#define INFO_LABEL_FONT_SIZE 17.0
#define INFO_TITLE_FONT_SIZE 9.0
#define SEPARATOR_HEIGHT 0.5
#define SEPARATOR_WIDTH 140

@interface RACRecipeViewController ()


@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (strong, nonatomic) UIView *imageTitleContainer;

@end

@implementation RACRecipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    
    self.scrollView.delegate = self;
    
    //Create image view.
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, IMAGE_HEIGHT)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.imageView setImageWithURL:[NSURL URLWithString:self.card.imageUrl]];
    [self.scrollView addSubview:self.imageView];
    
    self.titleView.text = self.card.title;
    
    self.navBar.alpha = 0;
    
    [self initInfoViews];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)initInfoViews {
    //Create labels' container.
    UIView *infosContainer = [[UIView alloc] initWithFrame:CGRectMake(0, IMAGE_HEIGHT, self.scrollView.contentSize.width, INFOS_CONTAINER_HEIGHT)];
    
    float containerWidth = self.scrollView.contentSize.width / 3;
    
    //Create label views.
    UILabel *firstInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        INFO_LABEL_TOP_MARGIN,
                                                                        containerWidth,
                                                                        INFO_LABEL_HEIGHT)];
    UILabel *secondInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(containerWidth,
                                                                         INFO_LABEL_TOP_MARGIN,
                                                                         containerWidth,
                                                                         INFO_LABEL_HEIGHT)];
    UILabel *thirdInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * containerWidth,
                                                                        INFO_LABEL_TOP_MARGIN,
                                                                        containerWidth,
                                                                        INFO_LABEL_HEIGHT)];
    UILabel *firstInfoTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                             INFO_LABEL_TOP_MARGIN + INFO_LABEL_HEIGHT,
                                                                             containerWidth,
                                                                             INFO_TITLE_LABEL_HEIGHT)];
    UILabel *secondInfoTitle = [[UILabel alloc] initWithFrame:CGRectMake(containerWidth,
                                                                              INFO_LABEL_TOP_MARGIN + INFO_LABEL_HEIGHT,
                                                                              containerWidth,
                                                                              INFO_TITLE_LABEL_HEIGHT)];
    UILabel *thirdInfoTitle = [[UILabel alloc] initWithFrame:CGRectMake(2 * containerWidth,
                                                                             INFO_LABEL_TOP_MARGIN + INFO_LABEL_HEIGHT,
                                                                             containerWidth,
                                                                             INFO_TITLE_LABEL_HEIGHT)];
    
    //Set labels' color.
    firstInfoLabel.textColor = [RACGraphics red];
    secondInfoLabel.textColor = [RACGraphics red];
    thirdInfoLabel.textColor = [RACGraphics red];
    firstInfoTitle.textColor = [UIColor lightGrayColor];
    secondInfoTitle.textColor = [UIColor lightGrayColor];
    thirdInfoTitle.textColor = [UIColor lightGrayColor];
    
    //Set labels' alignment.
    firstInfoLabel.textAlignment = NSTextAlignmentCenter;
    secondInfoLabel.textAlignment = NSTextAlignmentCenter;
    thirdInfoLabel.textAlignment = NSTextAlignmentCenter;
    firstInfoTitle.textAlignment = NSTextAlignmentCenter;
    secondInfoTitle.textAlignment = NSTextAlignmentCenter;
    thirdInfoTitle.textAlignment = NSTextAlignmentCenter;
    
    //Set labels' font.
    firstInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:INFO_LABEL_FONT_SIZE];
    secondInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:INFO_LABEL_FONT_SIZE];
    thirdInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:INFO_LABEL_FONT_SIZE];
    firstInfoTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:INFO_TITLE_FONT_SIZE];
    secondInfoTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:INFO_TITLE_FONT_SIZE];
    thirdInfoTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:INFO_TITLE_FONT_SIZE];
    
    //Set labels' content.
    firstInfoTitle.text = [NSLocalizedString(@"healthy", nil) uppercaseString];
    secondInfoTitle.text = [NSLocalizedString(@"time", nil) uppercaseString];
    thirdInfoTitle.text = [NSLocalizedString(@"price", nil) uppercaseString];
    
    firstInfoLabel.text = [NSString stringWithFormat:@"%ld%%", self.card.healthScore];
    secondInfoLabel.text = [NSString stringWithFormat:@"%ld %@", self.card.duration, NSLocalizedString(@"min", nil)];
    
    NSString *priceStr = @"";
    
    for (NSInteger i = 0; i < self.card.price + 1; i++) {
        priceStr = [priceStr stringByAppendingString:@"$"];
    }
    
    thirdInfoLabel.text = priceStr;
    
    //Add label subviews.
    [infosContainer addSubview:firstInfoLabel];
    [infosContainer addSubview:secondInfoLabel];
    [infosContainer addSubview:thirdInfoLabel];
    [infosContainer addSubview:firstInfoTitle];
    [infosContainer addSubview:secondInfoTitle];
    [infosContainer addSubview:thirdInfoTitle];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake((infosContainer.frame.size.width - SEPARATOR_WIDTH)/2,
                                                                 infosContainer.frame.size.height - SEPARATOR_HEIGHT,
                                                                 SEPARATOR_WIDTH,
                                                                 SEPARATOR_HEIGHT)];
    separator.backgroundColor = [UIColor lightGrayColor];
    [infosContainer addSubview:separator];
    
    [self.scrollView addSubview:infosContainer];
}

- (void)initIngredientsView {
    NSArray *ingredients = @[@"1 pack of cherry tomatoes,
                             @"1 pack of cherry size mozzarella",
                             @"1 pack of fresh basil leaves",
                             @"Olive oil",
                             @"Balsamic vinagar"];
    
    NSString *ingredientsString = @"";
    
    for (NSString *ingredient in ingredients) {
        ingredientsString = [ingredientsString stringByAppendingFormat:@"%@\n", ingredient];
    }
    
    UITextView *ingredientsView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, ingredientsString, <#CGFloat height#>)]
    
    UIView *ingredientsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, IMAGE_HEIGHT + INFOS_CONTAINER_HEIGHT, <#CGFloat width#>, <#CGFloat height#>)
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float yOffset = scrollView.contentOffset.y;
    
    //Nav bar fades while scrolling.
    self.navBar.alpha = MAX(0, yOffset / IMAGE_HEIGHT);
    
    //Zoom effect on image when scroll view top is reached.
    if (yOffset < 0) {
        self.imageView.frame = CGRectMake(0, yOffset, self.imageView.frame.size.width, IMAGE_HEIGHT - yOffset);
    }
}


@end
