//
//  ParseOperation.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "ParseSizesOperation.h"
#import "PhotoSizesObject.h"

static NSString * const kPhotoElementName = @"photo";
static NSString * const kSizesElementName = @"sizes";
static NSString * const kSizeElementName = @"size";
static NSString * const kLabelAttributeName = @"label";
static NSString * const kWidthAttributeName = @"width";
static NSString * const kHeightAttributeName = @"height";
static NSString * const kSourceAttributeName = @"source";

NSString *kAddPhotoSizesNotif = @"kAddPhotoSizesNotif";
NSString *kPhotoSizesResultsKey = @"kPhotoSizesResultsKey";
NSString *kPhotoSizesErrorNotif = @"kPhotoSizesErrorNotif";
NSString *kPhotoSizesMsgErrorKey = @"kPhotoSizesMsgErrorKey";

@interface ParseSizesOperation () <NSXMLParserDelegate>

@property (nonatomic, copy) ArrayBlock completionHandler;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) PhotoSizesObject *workingEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;

@end

@implementation ParseSizesOperation

@synthesize completionHandler, errorHandler, dataToParse, workingArray, workingEntry, workingPropertyString, elementsToParse, storingCharacterData;

- (id)initWithData:(NSData *)parseData completionHandler:(ArrayBlock)handler
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = parseData;
        self.completionHandler = handler;
        self.elementsToParse = [NSArray arrayWithObjects:kPhotoElementName, kSizesElementName, kLabelAttributeName, kWidthAttributeName, kHeightAttributeName, kSourceAttributeName, nil];
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
   
    if ([elementName isEqualToString:kSizesElementName]) {
        self.workingEntry = [[PhotoSizesObject alloc] init];
        storingCharacterData = YES;
    } else if ([elementName isEqualToString:kSizeElementName]) {
        NSString *labelAttribute = [attributeDict valueForKey:kLabelAttributeName];
        NSString *sourceAttribute = [attributeDict valueForKey:kSourceAttributeName];
        if (labelAttribute == @"thumbnail") {
          self.workingEntry.thumbnail = sourceAttribute;
        } else if (labelAttribute == @"small") {
            self.workingEntry.small = sourceAttribute;
        } else if (labelAttribute == @"medium") {
            self.workingEntry.medium = sourceAttribute;
        } else if (labelAttribute == @"original") {
            self.workingEntry.original = sourceAttribute;
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    
    if (self.workingEntry)
	{
        if ([elementName isEqualToString:kSizesElementName])
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoSizesErrorNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:parseError
                                                                                           forKey:kPhotoSizesMsgErrorKey]];
}


- (void)addPhotosToList:(NSArray *)photos {
    assert([NSThread isMainThread]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddPhotoSizesNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:photos
                                                                                           forKey:kPhotoSizesResultsKey]];
}   

@end