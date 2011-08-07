/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKWindow                                                   *
 *******************************************************************************************************************
 * File:             MKWindow.m                                                                                    *
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

#import "MKWindow.h"

#pragma mark Implementation
@implementation MKWindow

#pragma mark Initialization
- (id)init {
	self = [super init];
	if( self ) {
		// Initialization code here.
	}
	return self;
}

- (void)dealloc {
	// Clean-up code here.
	[super dealloc];
}

#pragma mark Reimplemented parent methods
- (BOOL)canBecomeKeyWindow {
	return NO;
}

- (BOOL)canBecomeMainWindow {
	return NO;
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

@end
