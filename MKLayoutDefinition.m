/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKLayoutDefinition                                         *
 *******************************************************************************************************************
 * File:             MKLayoutDefinition.m                                                                          *
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

#import "MKLayoutDefinition.h"
#import "MKButton.h"

#pragma mark Constants
NSString * const kUntitledLayoutDefinition = @"Untitled Layout Definition";

NSString * const kXmlDefinitionDefinition = @"definition";
NSString * const kXmlDefinitionName = @"name";
NSString * const kXmlDefinitionBackground = @"background";
NSString * const kXmlDefinitionFilename = @"filename";
NSString * const kXmlDefinitionHeight = @"height";
NSString * const kXmlDefinitionWidth = @"width";
NSString * const kXmlDefinitionButtons = @"buttons";
NSString * const kXmlDefinitionButton = @"button";
NSString * const kXmlDefinitionId = @"id";
NSString * const kXmlDefinitionXStart = @"xStart";
NSString * const kXmlDefinitionYStart = @"yStart";
NSString * const kXmlDefinitionXEnd = @"xEnd";
NSString * const kXmlDefinitionYEnd = @"yEnd";

#pragma mark -
#pragma mark Implementation
@implementation MKLayoutDefinition

#pragma mark Initialization
- (id)init {
	self = [super init];
	if( self ) {
		layoutDefinitionName = [[NSString alloc] initWithString:kUntitledLayoutDefinition];
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
	[layoutDefinitionName release];
	[keyboardImage release];
	[currentButtons release];

	[super dealloc];
}

+ (id)layoutDefinition {
	return [[[[self class] alloc] init] autorelease];
}

+ (id)layoutDefinitionWithName:(NSString *)loadName {
	return [[[[self class] alloc] initWithName:loadName] autorelease];
}

#pragma mark XML Parser
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
		qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
#pragma unused (parser, namespaceURI, qualifiedName)
	if( [elementName isEqualToString:kXmlDefinitionButton] ) {
		int buttonID = [[attributeDict valueForKey:kXmlDefinitionId] intValue];
		if( buttonID < 1 ) {
			NSLog(@"Invalid button definition ID: %d", buttonID);
			return;
		}
		for( MKButton *eachButton in currentButtons ) {
			if( [eachButton buttonID] == buttonID ) {
				NSLog(@"Duplicate button definition ID: %d", buttonID);
				return;
			}
		}
		int xStart = [[attributeDict valueForKey:kXmlDefinitionXStart] intValue];
		int yStart = [[attributeDict valueForKey:kXmlDefinitionYStart] intValue];
		int xEnd = [[attributeDict valueForKey:kXmlDefinitionXEnd] intValue];
		int yEnd = [[attributeDict valueForKey:kXmlDefinitionYEnd] intValue];
		MKButton *newButton = [MKButton buttonWithID:buttonID xStart:xStart xEnd:xEnd yStart:yStart yEnd:yEnd];
		[currentButtons addObject:newButton];
	} else if( [elementName isEqualToString:kXmlDefinitionDefinition] ) {
		[self setLayoutDefinitionName:[attributeDict valueForKey:kXmlDefinitionName]];
	} else if( [elementName isEqualToString:kXmlDefinitionBackground] ) {
		[self setKeyboardImage:[NSImage imageNamed:[attributeDict valueForKey:kXmlDefinitionFilename]]];
		[self setLayoutSize:NSMakeSize([[attributeDict valueForKey:kXmlDefinitionWidth] integerValue],
				[[attributeDict valueForKey:kXmlDefinitionHeight] integerValue])];
	} else if( [elementName isEqualToString:kXmlDefinitionButtons] ) {
		// Skip
	} else {
		NSLog(@"Found invalid element %@ during layout definition parsing", elementName);
	}
}

/// sent when the parser begins parsing of the document.
- (void)parserDidStartDocument:(NSXMLParser *)parser {
#pragma unused (parser)
	[self setValid:YES];
}

/// sent when the parser has completed parsing. If this is encountered, the parse was successful.
- (void)parserDidEndDocument:(NSXMLParser *)parser {
#pragma unused (parser)
	if( ![self layoutDefinitionName] )
		[self setLayoutDefinitionName:kUntitledLayoutDefinition];
	if( ![self keyboardImage] )
		[self setValid:NO];
	NSSize size = [self layoutSize];
	if( size.height <= 0 || size.width <= 0 )
		[self setValid:NO];
}

/// ...and this reports a fatal error to the delegate. The parser will stop parsing.
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Parse Error at line %ld: %@", [parser lineNumber], parseError);
	[self setValid:NO];
}

/// If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
	NSLog(@"Validation Error at line %ld: %@", [parser lineNumber], validationError);
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

#pragma mark Utilities
- (MKButton *)buttonWithID:(int)buttonID {
	for( MKButton *eachButton in currentButtons ) {
		if( [eachButton buttonID] == buttonID )
			return eachButton;
	}
	return nil;
}

#pragma mark -
#pragma mark Properties
@synthesize layoutDefinitionName;
@synthesize layoutSize;
@synthesize keyboardImage;
@synthesize currentButtons;
@synthesize valid;

@end
