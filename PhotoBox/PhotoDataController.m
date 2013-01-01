//
//  PhotoDataController.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "PhotoDataController.h"
#import "PhotoObject.h"

@interface PhotoDataController ()

- (void)initializeDefaultList;
- (void)addPhotosToList:(NSArray *)photos;

-(NSUInteger)numberPhotos;
-(PhotoObject *)getPhotoAtIndex:(NSUInteger)theIndex;

@end

@implementation PhotoDataController

-(void)initializeDefaultList {
    NSMutableArray *newPhotoList = [[NSMutableArray alloc] init];
    self.masterPhotoList = newPhotoList;
}

- (void)setMasterPhotoList:(NSMutableArray *)newPhotoList {
    if (_masterPhotoList != newPhotoList) {
        _masterPhotoList = [newPhotoList mutableCopy];
    }
}

- (id)init {
    if (self = [super init]) {
        [self initializeDefaultList];
        return self;
    }
    return nil;
}

-(NSUInteger)numberPhotos {
    return [self.masterPhotoList count];
}

-(PhotoObject *)getPhotoAtIndex:(NSUInteger)theIndex {
    NSLog(@"DataController getPhotoAtIndex: %u", theIndex);
    return [self.masterPhotoList objectAtIndex:theIndex];
}

- (void)addPhotosToList:(NSArray *)photos {
    [self.masterPhotoList addObjectsFromArray:photos];
    
    NSLog(@"addPhotos, %u", self.numberPhotos);
    // tell our table view to reload its data, now that parsing has completed
    // [rootViewController.tableView reloadData];}
}

@end
