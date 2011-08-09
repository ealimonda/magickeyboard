/*******************************************************************************************************************
 *                                     MagicKeyboard :: AlphaAnimation                                             *
 *******************************************************************************************************************
 * File:             AlphaAnimation.m                                                                              *
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

#import "AlphaAnimation.h"

#pragma mark Constants
NSString * const AAFadeIn  = @"AAFadeIn";
NSString * const AAFadeOut = @"AAFadeOut";

#pragma mark -
#pragma mark Implementation
@implementation AlphaAnimation 

#pragma mark Initialization
- (id)initWithDuration:(NSTimeInterval)aDuration effect:(NSString *)anEffect object:(NSView *)anObject {
	self = [super initWithDuration:aDuration animationCurve:0];
	if (self) {
		animatedObject = [anObject retain];
		effect = [anEffect retain];
	}
	return self;
}

- (void)dealloc {
	[animatedObject release];
	[effect release];
	[super dealloc];
}

#pragma mark Utilities
- (void)setCurrentProgress:(NSAnimationProgress)progress {
	[super setCurrentProgress:progress];

	if ([effect isEqualToString:AAFadeIn])
		[animatedObject setAlphaValue:progress];
	else if ([effect isEqualToString:AAFadeOut])
		[animatedObject setAlphaValue:1 - progress];
}

#pragma mark -
#pragma mark Properties
@synthesize animatedObject;
@synthesize effect;

@end
