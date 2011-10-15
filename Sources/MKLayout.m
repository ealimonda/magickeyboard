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
NSString * const kUntitledLayout        = @"Untitled Layout";
NSString * const kUndefinedLayout       = @"Undefined";
NSString * const kUndefinedLayoutSymbol = @"␀";

NSString * const kLayoutLayoutName      = @"LayoutName";
NSString * const kLayoutDefinition      = @"Definition";
NSString * const kLayoutSymbol          = @"Symbol";
NSString * const kLayoutKeys            = @"Keys";
NSString * const kLayoutButtonID        = @"Button";
NSString * const kLayoutValue           = @"Value";
NSString * const kLayoutType            = @"Type";
NSString * const kLayoutsDirectory      = @"Layouts";

#pragma mark -
#pragma mark Implementation
@implementation MKLayout

#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {
		layoutIdentifier = [[NSString alloc] initWithString:kUndefinedLayout];
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
		[layoutIdentifier release];
		layoutIdentifier = [[NSString alloc] initWithString:loadName];
		[self loadPlist:loadName];
	}
	return self;
}

- (void)dealloc {
	[layoutIdentifier release];
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

- (void)loadPlist:(NSString *)fileName {
#ifdef __DEBUGGING__
	NSLog(@"Parsing: %@", fileName);
#endif // __DEBUGGING__
	NSDictionary *layout = [[NSDictionary alloc]
				initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"
										  inDirectory:kLayoutsDirectory]];
	if (layout)
		[self setValid:YES];
	
	[self setLayoutName:[layout valueForKey:kLayoutLayoutName]];
	[self setLayoutSymbol:[layout valueForKey:kLayoutSymbol]];
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
			NSString *type = [eachKey valueForKey:kLayoutType];
			NSString *value = [eachKey valueForKey:kLayoutValue];
			MKButton *newButton = [MKButton buttonWithButton:button type:type value:value];
			if (!newButton) {
				NSLog(@"Invalid button (id: %ld type: %@ value: %@", buttonID, type, value);
				[self setValid:NO];
				return;
			}
			[currentButtons addObject:newButton];
		}
	}

	if (![self layoutName])
		[self setLayoutName:kUntitledLayout];
	if (![self layoutSymbol])
		[self setLayoutSymbol:kUndefinedLayoutSymbol];
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

#pragma mark Utilities
- (NSArray *)createLabelsUsingSymbolsForLayouts:(NSDictionary *)layouts {
	NSFont *font = [NSFont fontWithName:@"Lucida Grande" size:20];

	NSMutableArray *keys = [[[NSMutableArray alloc] init] autorelease];

	for (MKButton *eachKey in currentButtons) {
		NSString *volMuteSymbol = [NSString stringWithCharacters:(unichar[]){0xD83D, 0xDD08} length:2];
		NSString *volDownSymbol = [NSString stringWithCharacters:(unichar[]){0xD83D, 0xDD09} length:2];
		NSString *volUpSymbol = [NSString stringWithCharacters:(unichar[]){0xD83D, 0xDD0A} length:2];
		NSDictionary *keySymbolReplacements = [NSDictionary dictionaryWithObjectsAndKeys:
						       @"⏎", @"RETURN",
						       @"⌫", @"DELETE",
						       @"⌧", @"KP_CLEAR",
						       @"⌧", @"CLEAR",
						       @"⌤", @"KP_ENTER",
						       @"⌤", @"ENTER",
						       @"⎋", @"ESCAPE",
						       @"⇥", @"TAB",
						       @"↑", @"UP",
						       @"↓", @"DOWN",
						       @"←", @"LEFT",
						       @"→", @"RIGHT",
						       @"space", @"SPACE",
						       @"⌘", @"COMMAND",
						       @"⇧", @"SHIFT",
						       @"⇧", @"SHIFTR",
						       @"⇪", @"CAPS_LOCK",
						       @"⌥", @"OPTION",
						       @"⌥", @"OPTIONR",
						       @"⌃", @"CONTROL",
						       @"⌃", @"CONTROLR",
						       @"Fn", @"FN",
						       volUpSymbol, @"VOL_UP",
						       volDownSymbol, @"VOL_DOWN",
						       volMuteSymbol, @"VOL_MUTE",
						       @"⒣", @"HELP",
						       @"↖", @"HOME",
						       @"↘", @"END",
						       @"⇞", @"PAGE_UP",
						       @"⇟", @"PAGE_DOWN",
						       @"⌦", @"FW_DELETE",
						       nil];

		NSString *label = nil;
		if ([eachKey isLayoutSwitch]) {
			MKLayout *thisLayout = [layouts valueForKey:[eachKey value]];
			if (thisLayout) {
				label = [thisLayout layoutSymbol];
			}
		}
		if (!label) {
			label = [[eachKey value] uppercaseString];
		}
		if (![label isEqualToString:@"@"] && [keySymbolReplacements valueForKey:label]) // "@" as key makes it crash
			label = [keySymbolReplacements valueForKey:label];

		NSSize labelSize = [label sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
							      font, NSFontAttributeName, nil]];
		NSRect textBoxRect = NSMakeRect((CGFloat)[eachKey xStart],
						(CGFloat)(([eachKey yStart]+[eachKey yEnd]-labelSize.height)/2), // S+(E-S)/2-h/2
						(CGFloat)[eachKey xEnd] - [eachKey xStart],
						(CGFloat)(labelSize.height));
		if ([[[self layoutDefinition] style] isEqualToString:kStyleAluminium] && [eachKey isSpecialButton])
			textBoxRect = NSMakeRect((CGFloat)([eachKey xEnd] - labelSize.width - 10),
						 (CGFloat)([eachKey yStart]-3),
						 (CGFloat)(labelSize.width+5),
						 (CGFloat)(labelSize.height));
		NSTextField *textField = [[[NSTextField alloc] initWithFrame:textBoxRect] autorelease];
		[textField setStringValue:label];

		[textField setEditable:NO];
		[textField setSelectable:NO];
		if ([[[self layoutDefinition] style] isEqualToString:kStyleAluminium]) {
			[textField setTextColor:[NSColor colorWithSRGBRed:0.40 green:0.45 blue:0.50 alpha:1.0]];
			if ([eachKey isSpecialButton]) {
				[textField setFont:[NSFont fontWithName:@"Futura" size:11]];
			} else {
				[textField setFont:[NSFont fontWithName:@"Futura" size:16]];
			}
		} else if ([eachKey isSpecialButton]) {
			if ([[[eachKey value] uppercaseString] isEqualToString:@"SPACE"])
				[textField setTextColor:[NSColor darkGrayColor]];
			else
				[textField setTextColor:[NSColor whiteColor]];
			[textField setFont:font];
		}
		[textField setBackgroundColor:[NSColor clearColor]];
		[textField setBordered:NO];
		[textField setAlignment:NSCenterTextAlignment];
		[keys addObject:textField];
	}
	return keys;
}

- (CGFloat)ratio {
	return [self layoutSize].width / [self layoutSize].height;
}

#pragma mark -
#pragma mark Properties
@synthesize layoutIdentifier;
@synthesize layoutName;
@synthesize layoutSymbol;
@synthesize layoutSize;
@synthesize keyboardImage;
@synthesize currentButtons;
@synthesize valid;
@synthesize layoutDefinition;

@end
