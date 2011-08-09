/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKFinger.m                                                                                    *
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

#import "MKFinger.h"

#pragma mark Implementation
@implementation MKFinger

#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {
		active = NO;
		tapView = nil;
		last = 0L;
	}
	return self;
}

- (void)dealloc {
	[tapView release];
	[super dealloc];
}

+ (id)finger {
	return [[[[self class] alloc] init] autorelease];
}

#pragma mark -
#pragma mark Properties
@synthesize active;
@synthesize tapView;
@synthesize last;

@end
