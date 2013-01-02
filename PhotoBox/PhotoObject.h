//
//  PhotoObject.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoSizesObject;

@interface PhotoObject : NSObject

@property (nonatomic, copy) NSString *photoID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *user;

@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *small;
@property (nonatomic, copy) NSString *medium;
@property (nonatomic, copy) NSString *original;

@property (nonatomic, copy) UIImage *thumbImage;
@property (nonatomic, copy) UIImage *photoImage;

-(id)initWithID:(NSString *)photoID userID:(NSString *)userID title:(NSString *)title user:(NSString *)user;

@end
