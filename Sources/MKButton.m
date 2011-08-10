/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKButton                                                   *
 *******************************************************************************************************************
 * File:             MKButton.m                                                                                    *
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

#import "MKButton.h"

#pragma mark Constants
NSString * const kButtonTypeSymbol   = @"Symbol";
NSString * const kButtonTypeKeypad   = @"Keypad";
NSString * const kButtonTypeSpecial  = @"Special";
NSString * const kButtonTypeModifier = @"Modifier";

#pragma mark Implementation
@implementation MKButton

#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {
		type = nil;
		value = nil;
		xStart = 0;
		xEnd = 0;
		yStart = 0;
		yEnd = 0;
		specialButton = NO;
	}
	return self;
}

- (id)initWithID:(NSInteger)aButtonID xStart:(NSInteger)aXStart xEnd:(NSInteger)aXEnd yStart:(NSInteger)aYStart
	    yEnd:(NSInteger)aYEnd special:(BOOL)isSpecial {
	self = [self init];
	if (self) {
		buttonID = aButtonID;
		xStart = aXStart;
		xEnd = aXEnd;
		yStart = aYStart;
		yEnd = aYEnd;
		specialButton = isSpecial;
	}
	return self;
}

- (void)dealloc {
	[type release];
	[value release];
	[super dealloc];
}

+ (id)button {
	return [[[[self class] alloc] init] autorelease];
}

+ (id)buttonWithID:(NSInteger)aButtonID xStart:(NSInteger)aXStart xEnd:(NSInteger)aXEnd yStart:(NSInteger)aYStart
	      yEnd:(NSInteger)aYEnd special:(BOOL)isSpecial {
	return [[[[self class] alloc] initWithID:aButtonID xStart:aXStart xEnd:aXEnd yStart:aYStart yEnd:aYEnd
					 special:isSpecial] autorelease];
}

+ (id)buttonWithButton:(MKButton *)aButton type:(NSString *)aType value:(NSString *)aValue {
	MKButton *thisButton = [aButton copy];
	if (![[self class] isValidType:aType])
		return nil;
	[thisButton assignType:aType value:aValue];
	return [thisButton autorelease];
}

#pragma mark Special accessors
- (id)assignType:(NSString *)aType value:(NSString *)aValue {
	[self setType:aType];
	[self setValue:aValue];
	return self;
}

#pragma mark Utilities
- (BOOL)containsPoint:(NSPoint)aPoint size:(NSSize)circleSize {
	if (aPoint.x >= (xStart - (circleSize.width/2))
	    && (aPoint.x + (circleSize.width /2)) <= xEnd
	    && aPoint.y >= (yStart - (circleSize.height/2))
	    && (aPoint.y+(circleSize.height/2)) <=yEnd) {
		return YES;
	}
	return NO;
}

+ (BOOL)isValidType:(NSString *)aType {
	if (
	    [aType isEqualToString:kButtonTypeSymbol]
	    ||[aType isEqualToString:kButtonTypeKeypad]
	    ||[aType isEqualToString:kButtonTypeSpecial]
	    ||[aType isEqualToString:kButtonTypeModifier]
	    )
		return YES;
	if ([aType isEqualToString:@"NYI"]) { // FIXME
		NSLog(@"FIXME: NYI button type");
		return YES;
	}
	return NO;
}

- (BOOL)isSingleKeypress {
	if ([[self type] isEqualToString:kButtonTypeSymbol])
		return YES;
	if ([[self type] isEqualToString:kButtonTypeKeypad])
		return YES;
	if ([[self type] isEqualToString:kButtonTypeSpecial])
		return YES;
	return NO;
}

- (BOOL)isModifier {
	if ([[self type] isEqualToString:kButtonTypeModifier])
		return YES;
	return NO;
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] initWithID:[self buttonID] xStart:[self xStart] xEnd:[self xEnd]
						      yStart:[self yStart] yEnd:[self yEnd]
						     special:[self isSpecialButton]];
}

#pragma mark -
#pragma mark Properties
@synthesize buttonID;
@synthesize xStart;
@synthesize xEnd;
@synthesize yStart;
@synthesize yEnd;
@synthesize value;
@synthesize type;
@synthesize specialButton;

@end
