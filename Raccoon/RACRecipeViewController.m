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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (strong, nonatomic) UIView *imageTitleContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *firstInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *secondInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *thirdInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *firstInfoView;
@property (weak, nonatomic) IBOutlet UILabel *secondInfoView;
@property (weak, nonatomic) IBOutlet UILabel *thirdInfoView;

@end

@implementation RACRecipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    
    //Set scroll view size based on image width.
    self.imageWidthConstraint.constant = self.view.frame.size.width;
    [self.scrollView setNeedsUpdateConstraints];
    
    //Set recipe image.
    [self.imageView setImageWithURL:[NSURL URLWithString:self.card.imageUrl]];
    
    self.titleView.text = self.card.title;
    
    self.navBar.alpha = 0;
    
//    [self initInfoViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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


- (void)initIngredientsView {
    NSArray *ingredients = @[@"1 pack of cherry tomatoes",
                             @"1 pack of cherry size mozzarella",
                             @"1 pack of fresh basil leaves",
                             @"Olive oil",
                             @"Balsamic vinagar"];
    
    NSString *ingredientsString = @"";
    
    for (NSString *ingredient in ingredients) {
        ingredientsString = [ingredientsString stringByAppendingFormat:@"%@\n", ingredient];
    }
    
//    UITextView *ingredientsView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, ingredientsString, <#CGFloat height#>)]
//    
//    UIView *ingredientsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, IMAGE_HEIGHT + INFOS_CONTAINER_HEIGHT, <#CGFloat width#>, <#CGFloat height#>)
}

- (void) initRecipeStepView {
    UITextView *descriptionView = [UITextView new];
    descriptionView.text = @"This is a long description. This is a long description. This is a long description. This is a long description. This is a long description. This is a long description. \n This is a long description. This is a long description. \n This is a long description. This is a long description. This is a long description. This is a long description. This is a long description.";
//    [descriptionView sizeThatFits:]
    
    
//    UIView *stepView = [[UIView alloc] initWithFrame:<#(CGRect)#>]
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
