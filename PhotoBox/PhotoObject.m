//
//  PhotoObject.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "PhotoObject.h"


@implementation PhotoObject

-(id)initWithID:(NSString *)photoID userID:(NSString *)userID title:(NSString *)title user:(NSString *)user {
    self = [super init];
    if (self) {
        _photoID = photoID;
        _userID = userID;
        _title = title;
        _user = user;
        return self;
    }
    return nil;
}

-(id)addImages:(NSString *)thumb small:(NSString *)small medium:(NSString *)medium original:(NSString *)original {
    if (self) {
        _thumb = thumb;
        _small = small;
        _medium = medium;
        _original = original;
        return self;
    }
    return nil;
}

@end
