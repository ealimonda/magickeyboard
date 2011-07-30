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
#import "MKLayoutDefinition.h"
#import "MKButton.h"

NSString * const kUntitledLayout = @"Untitled Layout";

NSString * const kXmlLayoutLayout = @"layout";
NSString * const kXmlLayoutName = @"name";
NSString * const kXmlLayoutDefinition = @"definition";
NSString * const kXmlLayoutFilename = @"filename";
NSString * const kXmlLayoutKeys = @"keys";
NSString * const kXmlLayoutKey = @"key";
NSString * const kXmlLayoutLetter = @"letter";
NSString * const kXmlLayoutKeycode = @"keycode";
NSString * const kXmlLayoutButton = @"button";

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
		layoutDefinition = nil;
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
	[layoutDefinition release];

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
	if( [elementName isEqualToString:kXmlLayoutKey] ) {
		if( !layoutDefinition ) {
			NSLog(@"Invalid entry, no layout definition loaded.");
			return;
		}
		int buttonID = [[attributeDict valueForKey:kXmlLayoutButton] intValue];
		NSString *letter = [attributeDict valueForKey:kXmlLayoutLetter];
		NSString *keycode = [attributeDict valueForKey:kXmlLayoutKeycode];
		for( MKButton *eachButton in currentButtons ) {
			if( [eachButton buttonID] == buttonID ) {
				NSLog(@"Duplicate key button ID: %d", buttonID);
				return;
			}
		}
		MKButton *button = [layoutDefinition buttonWithID:buttonID];
		if( !button) {
			NSLog(@"Invalid key, button %d does not exist", buttonID);
			return;
		}
		[currentButtons addObject:[MKButton buttonWithButton:button letter:letter keycode:keycode]];
	} else if( [elementName isEqualToString:kXmlLayoutLayout] ) {
		[self setLayoutName:[attributeDict valueForKey:kXmlLayoutName]];
		[self loadLayoutDefinition:[attributeDict valueForKey:kXmlLayoutDefinition]];
	} else if( [elementName isEqualToString:kXmlLayoutKeys] ) {
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
	if( ![self layoutDefinition] || ![[self layoutDefinition] isValid] ) {
		[self setValid:NO];
		return;
	}
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

- (void)loadLayoutDefinition:(NSString *)definitionName {
	[self setLayoutDefinition:[MKLayoutDefinition layoutDefinitionWithName:definitionName]];
	if( [self layoutDefinition] && ![[self layoutDefinition] isValid] )
		[self setLayoutDefinition:nil];
	if( ![self layoutDefinition] ) {
		[self setValid:NO];
		return;
	}
	[self setLayoutSize:[[self layoutDefinition] layoutSize]];
	[self setKeyboardImage:[[self layoutDefinition] keyboardImage]];
}

- (NSArray *)createLabels {
	NSMutableArray *keys = [[[NSMutableArray alloc] init] autorelease];
	for( MKButton *eachKey in currentButtons ) {
		
		NSFont *font = [NSFont fontWithName:@"Lucida Grande" size:20];
		NSSize labelSize = [[[eachKey letter] uppercaseString]
				sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,
				NSFontAttributeName, nil]];
		NSRect textBoxRect = NSMakeRect((CGFloat)[eachKey xStart],
				(CGFloat)([eachKey yStart] + ([eachKey yEnd]-[eachKey yStart])/2 - labelSize.height/2),
				(CGFloat)[eachKey xEnd] - [eachKey xStart],
				(CGFloat)(labelSize.height));
		NSTextField *textField = [[[NSTextField alloc] initWithFrame:textBoxRect] autorelease];
		[textField setStringValue:[[eachKey letter] uppercaseString]];

		[textField setEditable:NO];
		[textField setSelectable:NO];
// TODO		[textField setTextColor:(NSColor *)];
		[textField setBackgroundColor:[NSColor clearColor]];
		[textField setBordered:NO];
		[textField setFont:font];
		[textField setAlignment:NSCenterTextAlignment];
		[keys addObject:textField];
	}
	return keys;
}

@synthesize layoutName;
@synthesize layoutSize;
@synthesize keyboardImage;
@synthesize currentButtons;
@synthesize valid;
@synthesize layoutDefinition;

@end
