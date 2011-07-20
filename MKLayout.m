/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKLayout                                                   *
 *******************************************************************************************************************
 * File:             MKLayout.m                                                                                    *
 * Copyright:        (c) 2011 alimonda.com; Emanuele Alimonda                                                      *
 *                   This software is free software: you can redistribute it and/or modify it under the terms of   *
 *                       the GNU General Public License as published by the Free Software Foundation, either       *
 *                       version 3 of the License, or (at your option) any later version.                          *
 *                   This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;    *
 *                       without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. *
 *                   See the GNU General Public License for more details.                                          *
 *                   You should have received a copy of the GNU General Public License along with this program.    *
 *                       If not, see <http://www.gnu.org/licenses/>                                                *
 *******************************************************************************************************************/

#import "MKLayout.h"
#import "MKButton.h"

NSString * const kUntitledLayout = @"Untitled Layout";

NSString * const kXmlLayout = @"layout";
NSString * const kXmlName = @"name";
NSString * const kXmlBackground = @"background";
NSString * const kXmlFilename = @"filename";
NSString * const kXmlHeight = @"height";
NSString * const kXmlWidth = @"width";
NSString * const kXmlButtons = @"buttons";
NSString * const kXmlButton = @"button";
NSString * const kXmlLetter = @"letter";
NSString * const kXmlKeycode = @"keycode";
NSString * const kXmlXStart = @"xStart";
NSString * const kXmlYStart = @"yStart";
NSString * const kXmlXEnd = @"xEnd";
NSString * const kXmlYEnd = @"yEnd";

@implementation MKLayout

#pragma mark Initialization
- (id)init {
	self = [super init];
	if( self ) {
		layoutName = [[NSString alloc] initWithString:kUntitledLayout];
		layoutSize = NSMakeSize(0, 0);
		keyboardImage = nil;
		currentButtons = [[NSMutableArray alloc] init];
		valid = NO;
	}
	return self;
}

- (id)initWithName:(NSString *)loadName {
	self = [self init];
	if( self ) {
		[self loadXML:loadName];
	}
	return self;
}

- (void)dealloc {
	[layoutName release];
	[keyboardImage release];
	[currentButtons release];

	[super dealloc];
}

+ (id)layout {
	return [[[[self class] alloc] init] autorelease];
}

+ (id)layoutWithName:(NSString *)loadName {
	return [[[[self class] alloc] initWithName:loadName] autorelease];
}

#pragma mark XML Parser
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
		qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
#pragma unused (parser, namespaceURI, qualifiedName)
	if( [elementName isEqualToString:kXmlButton] ) {
		NSString *letter = [attributeDict valueForKey:kXmlLetter];
		NSString *keycode = [attributeDict valueForKey:kXmlKeycode];
		int xStart = [[attributeDict valueForKey:kXmlXStart] intValue];
		int yStart = [[attributeDict valueForKey:kXmlYStart] intValue];
		int xEnd = [[attributeDict valueForKey:kXmlXEnd] intValue];
		int yEnd = [[attributeDict valueForKey:kXmlYEnd] intValue];
		MKButton *newButton = [MKButton buttonWithLetter:letter keycode:keycode xStart:xStart xEnd:xEnd
								 yStart:yStart yEnd:yEnd];
		[currentButtons addObject:newButton];
	} else if( [elementName isEqualToString:kXmlLayout] ) {
		[self setLayoutName:[attributeDict valueForKey:kXmlName]];
	} else if( [elementName isEqualToString:kXmlBackground] ) {
		[self setKeyboardImage:[NSImage imageNamed:[attributeDict valueForKey:kXmlFilename]]];
		[self setLayoutSize:NSMakeSize([[attributeDict valueForKey:kXmlWidth] integerValue],
				[[attributeDict valueForKey:kXmlHeight] integerValue])];
	} else if( [elementName isEqualToString:kXmlButtons] ) {
		// Skip
	} else {
		NSLog(@"Found invalid element %@ during layout parsing", elementName);
	}
	
}

// sent when the parser begins parsing of the document.
- (void)parserDidStartDocument:(NSXMLParser *)parser {
#pragma unused (parser)
	//#ifdef __DEBUGGING__
	//	NSLog(@"%s:%s:%d", __PRETTY_FUNCTION__, __FILE__, __LINE__);
	//#endif // __DEBUGGING__
	[self setValid:YES];
}

// sent when the parser has completed parsing. If this is encountered, the parse was successful.
- (void)parserDidEndDocument:(NSXMLParser *)parser {
#pragma unused (parser)
	//#ifdef __DEBUGGING__
	//	NSLog(@"%s:%s:%d", __PRETTY_FUNCTION__, __FILE__, __LINE__);
	//#endif // __DEBUGGING__
	if( ![self layoutName] )
		[self setLayoutName:kUntitledLayout];
	if( ![self keyboardImage] )
		[self setValid:NO];
	NSSize size = [self layoutSize];
	if( size.height <= 0 || size.width <= 0 )
		[self setValid:NO];
}

/// ...and this reports a fatal error to the delegate. The parser will stop parsing.
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Parse Error at line %d: %@", [parser lineNumber], parseError);
	[self setValid:NO];
}

/// If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
	NSLog(@"Validation Error at line %d: %@", [parser lineNumber], validationError);
	[self setValid:NO];
}

- (void)loadXML:(NSString *)xmlFileName {
	// Create a parser
#ifdef __DEBUGGING__
	NSLog(@"Parsing: %@", xmlFileName);
#endif // __DEBUGGING__
	NSData *xmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:xmlFileName ofType:@"xml"]];
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:xmlData] autorelease];
	[parser setDelegate:self];
	// Do the parse
	[parser parse];
}

@synthesize layoutName;
@synthesize layoutSize;
@synthesize keyboardImage;
@synthesize currentButtons;
@synthesize valid;

@end
