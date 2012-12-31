//
//  PhotoObject.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoObject : NSObject

@property (nonatomic, copy) NSString *photoID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *user;

@property (nonatomic, copy) NSString *thumb;
@property (nonatomic, copy) NSString *small;
@property (nonatomic, copy) NSString *medium;
@property (nonatomic, copy) NSString *original;

-(id)initWithID:(NSString *)photoID userID:(NSString *)userID title:(NSString *)title user:(NSString *)user;

-(id)addImages:(NSString *)thumb small:(NSString *)small medium:(NSString *)medium original:(NSString *)original;

@end
