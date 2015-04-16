//
//  RecipesCollectionVC.m
//  Raccoon
//
//  Created by Bastien Beurier on 4/15/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RecipesCollectionVC.h"
#import "RACApi.h"
#import "RACUtils.h"
#import "RecipeCell.h"
#import "RACRecipe.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "RACRecipeViewController.h"
#import "RACGraphics.h"

#define LOADING_BATCH 100
#define ITEM_SPACING 2

@interface RecipesCollectionVC ()

@property (strong, nonatomic) NSMutableArray *recipes;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@end

@implementation RecipesCollectionVC

#pragma mark - Overriden methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    self.recipes = [NSMutableArray new];
    
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    statusBarView.backgroundColor = [RACGraphics red];
    [self.view addSubview:statusBarView];
    
    [self loadRecipes:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;

    if ([segueName isEqualToString: @"Recipe Segue"]) {
        ((RACRecipeViewController *) [segue destinationViewController]).recipe = sender;
    }
}

#pragma mark - Loading methods

- (void)loadRecipes:(NSString *)text {
    self.recipes = [NSMutableArray new];
    [self.collectionView reloadData];
    [self.activity startAnimating];
    self.activity.hidden = NO;
    
    [RACApi getRecipes:text count:LOADING_BATCH orderBy:@"created_at" offset:0 success:^(NSArray *recipes) {
        [self.activity stopAnimating];
        self.activity.hidden = YES;
        
        [self.recipes addObjectsFromArray:recipes];
        [self.collectionView reloadData];
    } failure:^{
        //Connection problem, show alert dialog.
        [RACUtils showMessage:NSLocalizedString(@"no_connection_message", nil)
                forController:self
                    withTitle:NSLocalizedString(@"no_connection_title", nil)
                       action:NSLocalizedString(@"OK", nil)
                   completion:^{
                       [self loadRecipes:self.searchField.text];
                   }];
    }];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self loadRecipes:textField.text];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.recipes count];
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecipeCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"RecipeCell" forIndexPath:indexPath];
    RACRecipe *recipe = self.recipes[indexPath.row];
    
    //TODO BB: cache image in file system.
    
    
    //Set cell content.
    cell.imageView.image = nil;
    [cell.imageView setImageWithURL:[NSURL URLWithString:recipe.imageUrl]];
    cell.title.text = recipe.title;
    
    //Get image from cache or download it.
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        UIImage *image = [RACUtils getCachedImage:recipe.identifier];
        
        if (image) {
            //Image in cache. Show with animation.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [UIView transitionWithView:cell.imageView
                                  duration:0.2f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    cell.imageView.image = image;
                                } completion:NULL];
            }];
        } else {
            //download image
            NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:recipe.imageUrl]];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [UIView transitionWithView:cell.imageView
                                  duration:0.2f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    cell.imageView.image = [UIImage imageWithData:imageData];
                                } completion:NULL];
            }];
            
            //Cache image.
            [RACUtils setCachedImage:image forId:recipe.identifier];
        }
    }];
    
    //Shadow on title.
    cell.title.layer.shadowOpacity = 0.8;
    cell.title.layer.shadowRadius = 3.0;
    cell.title.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.title.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"Recipe Segue" sender:self.recipes[indexPath.row]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width/2 - ITEM_SPACING/2, collectionView.frame.size.width/2 - ITEM_SPACING/2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return ITEM_SPACING;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return ITEM_SPACING;
}


@end
