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
    // NSMutableArray *_objects;
}

-(void)setTableSource:(NSArray *)photos;

@end


@implementation PhotoBoxListViewController

- (void)awakeFromNib
{
    NSLog(@"ListVC awakeFromNib");
    [super awakeFromNib];
    if (self.dataController == nil) {
        self.dataController = [[PhotoDataController alloc] init];
    }
    
    [self.tableView reloadData];
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
    
    
    [[cell titleLabel] setText:@"Title"];
    [[cell userLabel] setText:@"User"];
    [[cell imageView] setImage:[UIImage imageNamed:@"2610_t.jpg"]];
    
    // [[cell setText:[NSString stringWithFormat:@"A am cell number %d",indexPath.row]]];
    // [[cell titleLabel] setText:sightingAtIndex.name];
    // [[cell detailTextLabel] setText:[formatter stringFromDate:(NSDate *)sightingAtIndex.date]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowFullScreenImage"]) {
        PhotoBoxDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.photo = [self.dataController getPhotoAtIndex:[self.tableView indexPathForSelectedRow].row];
        
    } else if ([[segue identifier] isEqualToString:@"ShowWebView"]) {
        PhotoBoxWebViewController *detailViewController = [segue destinationViewController];
        detailViewController.photo = [self.dataController getPhotoAtIndex:[self.tableView indexPathForSelectedRow].row];
        
    }
}

@end
