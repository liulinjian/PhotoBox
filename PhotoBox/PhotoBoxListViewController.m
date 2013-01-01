//
//  PhotoBoxMasterViewController.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "PhotoBoxListViewController.h"
#import "PhotoBoxDetailViewController.h"
#import "PhotoBoxWebViewController.h"

#import "PhotoDataController.h"
#import "PhotoObject.h"

@interface PhotoBoxListViewController () {
}

- (IBAction)handleFullScreenButton:(UIButton *)sender;
- (IBAction)handleWebViewButton:(UIButton *)sender;

-(void)setTableSource:(NSArray *)photos;

@end


@implementation PhotoBoxListViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"listVC viewDidLoad, %@", self.dataController);
    
    [self.tableView reloadData];
}


- (IBAction)handleFullScreenButton:(UIButton *)sender {
    self.currRow = (NSInteger *)sender.tag;
}

- (IBAction)handleWebViewButton:(UIButton *)sender {
    self.currRow = (NSInteger *)sender.tag;
}

- (void)setTableSource:(NSArray *)photos {
    NSLog(@"ListVC setTableSource");
    //NSLog(@"%d",self.dataController.numberPhotos);
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataController numberPhotos];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"PhotoCell";
    
    PhotoBoxCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSLog(@"Cell created!");
        // cell = [[PhotoBoxCustomCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier]; //autorelease
        
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PhotoBoxCustomCell" owner:nil options:nil];
        
        for(id currentObject in nibObjects)
        {
            if ([currentObject isKindOfClass:[PhotoBoxCustomCell class]])
            {
                cell = (PhotoBoxCustomCell *)currentObject;
            }
        }
        
    }
    
    NSLog(@"cell creation: %d",indexPath.row);
    [[cell titleLabel] setText:[self.dataController getPhotoAtIndex:indexPath.row].title];
    [[cell userLabel] setText:[self.dataController getPhotoAtIndex:indexPath.row].user];
    [[cell imageView] setImage:[UIImage imageNamed:@"2610_t.jpg"]];
    [[cell fullscreenButton] setTag:indexPath.row];
    [[cell webviewButton] setTag:indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSUInteger rowForAccess= (NSUInteger)self.currRow;
    PhotoObject *tempPhoto = [self.dataController getPhotoAtIndex:(NSUInteger)rowForAccess];
    // NSLog(@"ListVC prepareForSeque, %@",tempPhoto.photoID);
    
    if ([[segue identifier] isEqualToString:@"openFullScreen"]) {
        PhotoBoxDetailViewController *detailVC = [segue destinationViewController];
        detailVC.photo = tempPhoto;
        
    } else if ([[segue identifier] isEqualToString:@"openWebView"]) {
        PhotoBoxWebViewController *webviewVC = [segue destinationViewController];
        webviewVC.photo = tempPhoto;
        
    }
}


@end
