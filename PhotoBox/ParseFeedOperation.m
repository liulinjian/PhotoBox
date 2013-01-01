//
//  ParseOperation.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "ParseFeedOperation.h"
#import "PhotoObject.h"

static const const NSUInteger kMaximumNumberOfPhotosToParse = 50;

static NSUInteger const kSizeOfPhotoBatch = 10;

static NSString * const kPhotoElementName = @"photo";
static NSString * const kPhotoIDAttributeName = @"id";
static NSString * const kUserIDAttributeName = @"user_id";
static NSString * const kTitleAttributeName = @"title";
static NSString * const kUserAttributeName = @"user";

NSString *kAddPhotosNotif = @"AddPhotosNotif";
NSString *kPhotoResultsKey = @"PhotoResultsKey";
NSString *kPhotosErrorNotif = @"PhotoErrorNotif";
NSString *kPhotosMsgErrorKey = @"PhotosMsgErrorKey";


@interface ParseFeedOperation () <NSXMLParserDelegate>

@property (nonatomic, copy) ArrayBlock completionHandler;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) PhotoObject *workingEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;

@end

@implementation ParseFeedOperation

@synthesize completionHandler, errorHandler, dataToParse, workingArray, workingEntry, workingPropertyString, elementsToParse, storingCharacterData;

- (id)initWithData:(NSData *)parseData completionHandler:(ArrayBlock)handler
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = parseData;
        self.completionHandler = handler;
        self.elementsToParse = [NSArray arrayWithObjects:kPhotoElementName, kPhotoIDAttributeName, kUserIDAttributeName, kTitleAttributeName, kUserAttributeName, nil];
    }
    return self;
}

/**
- (void)dealloc
{
    [completionHandler release];
    [errorHandler release];
    [dataToParse release];
    [workingEntry release];
    [workingPropertyString release];
    [workingArray release];
    
    [super dealloc];
}
**/

- (void)main
{
	// NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.workingArray = [NSMutableArray array];
    self.workingPropertyString = [NSMutableString string];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataToParse];
	[parser setDelegate:self];
    [parser parse];
	
	if (![self isCancelled])
    {
        // call our completion handler with the result of our parsing
        self.completionHandler(self.workingArray);
    }
    
    /**
     if ([self.workingArray count] > 0) {
        [self performSelectorOnMainThread:@selector(addPhotosToList:)
                               withObject:self.workingArray
                            waitUntilDone:NO];
    }
     **/
    
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
    
    // [[parser release];
	// [pool release];
}

/**
- (void)dealloc {
    [photoData release];
    
    [currentPhotoObject release];
    [currentParsedCharacterData release];
    [currentParseBatch release];
    [dateFormatter release];
    
    [super dealloc];
}
**/

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                     namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName
                                     attributes:(NSDictionary *)attributeDict {
    // Limit # Photos to Parse
    /**
     if (parsedPhotosCounter >= kMaximumNumberOfPhotosToParse) {
        // flag didAbortParsing
        didAbortParsing = YES;
        [parser abortParsing];
    }
     **/
    if ([elementName isEqualToString:kPhotoElementName]) {
        self.workingEntry = [[PhotoObject alloc] init];
        
        NSString *photoIDAttribute = [attributeDict valueForKey:kPhotoIDAttributeName];
        self.workingEntry.photoID = photoIDAttribute;
        
        NSString *userIDAttribute = [attributeDict valueForKey:kUserIDAttributeName];
        self.workingEntry.userID = userIDAttribute;
        
        NSString *titleAttribute = [attributeDict valueForKey:kTitleAttributeName];
        self.workingEntry.title = titleAttribute;
        
        NSString *userAttribute = [attributeDict valueForKey:kUserAttributeName];
        self.workingEntry.user = userAttribute;
        
        // [photo release];
        
        storingCharacterData = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    
    if (self.workingEntry)
	{
        if ([elementName isEqualToString:kPhotoElementName])
        {
            [self.workingArray addObject:self.workingEntry];
            
            parsedPhotosCounter++;
            
            self.workingEntry = nil;
        }
    }
    storingCharacterData = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (storingCharacterData) {
        [self.workingPropertyString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.errorHandler(parseError);
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
    {
        [self performSelectorOnMainThread:@selector(handlePhotosError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
}

- (void)handlePhotosError:(NSError *)parseError {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotosErrorNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:parseError
                                                                                           forKey:kPhotosMsgErrorKey]];
}


- (void)addPhotosToList:(NSArray *)photos {
    assert([NSThread isMainThread]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddPhotosNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:photos
                                                                                           forKey:kPhotoResultsKey]];
}   

@end