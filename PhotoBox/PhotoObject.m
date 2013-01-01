//
//  PhotoObject.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "PhotoObject.h"


@implementation PhotoObject

-(id)initWithID:(NSString *)newphotoID userID:(NSString *)newuserID title:(NSString *)newtitle user:(NSString *)newuser {
    self = [super init];
    if (self) {
        self.photoID = newphotoID;
        self.userID = newuserID;
        self.title = newtitle;
        self.user = newuser;
        return self;
    }
    return nil;
}

@end
