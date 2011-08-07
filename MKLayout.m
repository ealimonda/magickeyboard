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

#pragma mark Constants
NSString * const kUntitledLayout = @"Untitled Layout";

NSString * const kLayoutLayoutName = @"LayoutName";
NSString * const kLayoutDefinition = @"Definition";
NSString * const kLayoutKeys = @"Keys";
NSString * const kLayoutButtonID = @"Button";
NSString * const kLayoutLetter = @"Letter";
NSString * const kLayoutKeycode = @"Keycode";

#pragma mark -
#pragma mark Implementation
@implementation MKLayout

#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {
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
	if (self) {
		[self loadPlist:loadName];
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

#pragma mark Utilities
- (void)loadPlist:(NSString *)fileName {
#ifdef __DEBUGGING__
	NSLog(@"Parsing: %@", fileName);
#endif // __DEBUGGING__
	NSDictionary *layout = [[NSDictionary alloc] initWithContentsOfFile:
				[[NSBundle mainBundle] pathForResource:
				 [NSString stringWithFormat:@"Lay_%@", fileName] ofType:@"plist"]];
	if (layout)
		[self setValid:YES];
	
	[self setLayoutName:[layout valueForKey:kLayoutLayoutName]];
	[self loadLayoutDefinition:[layout valueForKey:kLayoutDefinition]];
	if (![self layoutDefinition] || ![[self layoutDefinition] isValid]) {
		NSLog(@"Error: Invalid layout definition specified");
		[self setValid:NO];
		return;
	}

	NSDictionary *keys = [layout valueForKey:kLayoutKeys];
	if (keys) {
		for (NSDictionary *eachKey in keys) {
			NSInteger buttonID = [[eachKey valueForKey:kLayoutButtonID] integerValue];
			for (MKButton *eachButton in currentButtons) {
				if ([eachButton buttonID] == buttonID) {
					NSLog(@"Duplicate key button ID: %ld", buttonID);
					[self setValid:NO];
					return;
				}
			}
			MKButton *button = [layoutDefinition buttonWithID:buttonID];
			if (!button) {
				NSLog(@"Invalid key, button %ld does not exist", buttonID);
				[self setValid:NO];
				return;
			}
			NSString *letter = [eachKey valueForKey:kLayoutLetter];
			NSString *keycode = [eachKey valueForKey:kLayoutKeycode];
			[currentButtons addObject:[MKButton buttonWithButton:button letter:letter keycode:keycode]];
		}
	}

	if (![self layoutName])
		[self setLayoutName:kUntitledLayout];
}

- (void)loadLayoutDefinition:(NSString *)definitionName {
	[self setLayoutDefinition:[MKLayoutDefinition layoutDefinitionWithName:definitionName]];
	if ([self layoutDefinition] && ![[self layoutDefinition] isValid])
		[self setLayoutDefinition:nil];
	if (![self layoutDefinition]) {
		[self setValid:NO];
		return;
	}
	[self setLayoutSize:[[self layoutDefinition] layoutSize]];
	[self setKeyboardImage:[[self layoutDefinition] keyboardImage]];
}

- (NSArray *)createLabels {
	NSMutableArray *keys = [[[NSMutableArray alloc] init] autorelease];
	for (MKButton *eachKey in currentButtons) {
		
		NSFont *font = [NSFont fontWithName:@"Lucida Grande" size:20];
		NSSize labelSize = [[[eachKey letter] uppercaseString]
				    sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,
							NSFontAttributeName, nil]];
		NSRect textBoxRect = NSMakeRect((CGFloat)[eachKey xStart],
						(CGFloat)(([eachKey yStart]+[eachKey yEnd]-labelSize.height)/2), // S+(E-S)/2-h/2
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

#pragma mark -
#pragma mark Properties
@synthesize layoutName;
@synthesize layoutSize;
@synthesize keyboardImage;
@synthesize currentButtons;
@synthesize valid;
@synthesize layoutDefinition;

@end
