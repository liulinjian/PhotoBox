//
//  PhotoDataController.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoObject;

@interface PhotoDataController : NSObject

@property (nonatomic, copy) NSMutableArray *masterPhotoList;

-(NSUInteger)numberPhotos;
-(PhotoObject *)getPhotoAtIndex:(NSUInteger)theIndex;
-(void)initializeDefaultList;
-(void)addPhotosToList:(NSArray *)photos;

@end
