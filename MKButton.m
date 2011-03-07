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
 *******************************************************************************************************************
 * $Id::                                                                               $: SVN Info                 *
 * $Date::                                                                             $: Last modification        *
 * $Author::                                                                           $: Last modification author *
 * $Revision::                                                                         $: SVN Revision             *
 *******************************************************************************************************************/

#import "MKButton.h"

@implementation MKButton

- (id)init {
	self = [super init];
	if( self ) {
		letter = nil;
		keycode = nil;
		xStart = 0;
		xEnd = 0;
		yStart = 0;
		yEnd = 0;
	}
	return self;
}

- (id)initWithLetter:(NSString *)aLetter keycode:(NSString *)aKeycode xStart:(int)aXStart xEnd:(int)aXEnd
		yStart:(int)aYStart yEnd:(int)aYEnd {
	self = [self init];
	if( self ) {
		letter = [aLetter retain];
		keycode = [aKeycode retain];
		xStart = aXStart;
		xEnd = aXEnd;
		yStart = aYStart;
		yEnd = aYEnd;
	}
	return self;
}

- (void)dealloc {
	[letter release];
	[keycode release];
	[super dealloc];
}

+ (id)button {
	return [[[[self class] alloc] init] autorelease];
}

+ (id)buttonWithLetter:(NSString *)aLetter keycode:(NSString *)aKeycode xStart:(int)aXStart xEnd:(int)aXEnd
		yStart:(int)aYStart yEnd:(int)aYEnd {
	return [[[[self class] alloc] initWithLetter:aLetter keycode:aKeycode xStart:aXStart xEnd:aXEnd yStart:aYStart
			yEnd:aYEnd] autorelease];
}

- (BOOL)containsPoint:(NSPoint)aPoint size:(NSSize)circleSize {
#if 0
	if( [letter isEqualToString:@"q"] ) {
		NSLog(letter);
		NSLog(shift);
		NSLog([NSString stringWithFormat:@"%d", xStart]);
		NSLog([NSString stringWithFormat:@"%d", xEnd]);
		NSLog([NSString stringWithFormat:@"%d", yStart]);
		NSLog([NSString stringWithFormat:@"%d", yEnd]);
	}
#endif // 0
	if( aPoint.x >= (xStart - (circleSize.width/2)) && (aPoint.x + (circleSize.width /2)) <= xEnd
			&& aPoint.y >= (yStart - (circleSize.height/2)) && (aPoint.y+(circleSize.height/2)) <=yEnd ) {
		return YES;
	}
	return NO;
}

@synthesize xStart;
@synthesize xEnd;
@synthesize yStart;
@synthesize yEnd;
@synthesize keycode;
@synthesize letter;

@end
