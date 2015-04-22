//
//  RecipesCollectionVC.m
//  Raccoon
//
//  Created by Bastien Beurier on 4/15/15.
//  Copyright (c) 2015 Raccoon. All rights reserved.
//

#import "RACRecipesCollectionVC.h"
#import "RACApi.h"
#import "RACUtils.h"
#import "RACRecipeCell.h"
#import "RACRecipe.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "RACRecipeViewController.h"
#import "RACGraphics.h"
#import "Recipe+Utils.h"
#import "AppDelegate.h"

#define LOADING_BATCH 100
#define ITEM_SPACING 2
#define STATUS_BAR_HEIGHT 22

@interface RACRecipesCollectionVC ()

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property NSMutableArray *itemChanges;

@end

@implementation RACRecipesCollectionVC

#pragma mark - Overriden methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    //Fake status bar.
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, STATUS_BAR_HEIGHT)];
    statusBarView.backgroundColor = [RACGraphics red];
    [self.view addSubview:statusBarView];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    
    [[self fetchedResultsController] performFetch:NULL];
    [self loadServerRecipes];
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
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

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:NO]];
    request.fetchBatchSize = 20;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                    managedObjectContext:self.context
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)loadServerRecipes {
    //Load recipes from server.
    [RACApi getRecipes:nil count:LOADING_BATCH orderBy:@"created_at" offset:0 success:^(NSArray *serverRecipes) {
        [Recipe syncLocalRecipesWithServerRecipes:serverRecipes forContext:self.context];
    } failure:^{
        BOOL noLocalData = [[self.fetchedResultsController sections] count] == 0 ||
        [(id <NSFetchedResultsSectionInfo>) [[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] == 0;

        //If no local data, show alert dialog.
        if (noLocalData) {
            [RACUtils showMessage:NSLocalizedString(@"no_connection_message", nil)
                    forController:self
                        withTitle:NSLocalizedString(@"no_connection_title", nil)
                           action:NSLocalizedString(@"OK", nil)
                       completion:^{
                           [self loadServerRecipes];
                       }];
        }
    }];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    //TODO: not yet implemented.
    [self loadServerRecipes];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RACRecipeCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"RecipeCell" forIndexPath:indexPath];
    Recipe *recipe = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
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
            if (imageData) {
                [RACUtils setCachedImage:imageData forId:recipe.identifier];
            }
        }
    }];
    
    //Shadow on title.
    cell.title.layer.shadowOpacity = 0.8;
    cell.title.layer.shadowRadius = 3.0;
    cell.title.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.title.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    return cell;
}

#pragma mark - NSFetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.itemChanges = [[NSMutableArray alloc] init];
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [self.itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        for (NSDictionary *change in self.itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        self.itemChanges = nil;
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"Recipe Segue" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
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
