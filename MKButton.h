/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKButton                                                   *
 *******************************************************************************************************************
 * File:             MKButton.h                                                                                    *
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

#import <Cocoa/Cocoa.h>

@interface MKButton : NSObject {
	int xStart;
	int xEnd;
	int yStart;
	int yEnd;
	NSString *keycode;
	NSString *letter;
}

- (MKButton*)initWithLetter:(NSString *)aLetter keycode:(NSString *)aKeyCode xStart:(int)aXStart xEnd:(int)aXEnd
		yStart:(int)aYStart yEnd:(int)aYEnd;

- (BOOL)containsPoint:(NSPoint)aPoint size:(NSSize)circleSize;

@property (assign) int xStart;
@property (assign) int xEnd;
@property (assign) int yStart;
@property (assign) int yEnd;
@property (retain) NSString *keycode;
@property (retain) NSString *letter;

@end
