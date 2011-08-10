/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKController.h                                                                                *
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

#import <Cocoa/Cocoa.h>

@class MKWindow;
@class MKLayout;
@class MKKeyboard;

#pragma mark Interface
@interface MKController : NSObject {
	IBOutlet MKWindow *window;
	IBOutlet NSButton *shiftChk;
	IBOutlet NSButton *cmdChk;
	IBOutlet NSButton *ctrlChk;
	IBOutlet NSButton *altChk;

	IBOutlet NSMenuItem *selQwerty;
	IBOutlet NSMenuItem *selFullNum;
	BOOL cmd;
	BOOL alt;
	BOOL ctrl;
	BOOL tracking;
	NSSize mtSize;
	IBOutlet NSImageView *keyboardImage;
	BOOL shift;
	BOOL lastKeyWasModifier;
	IBOutlet NSView *keyboardView;
	NSMutableArray *keyLabels;

	NSSound *tapSound;
	NSImage *tap;

	MKLayout *currentLayout;
	MKKeyboard *keyboard;

	NSMutableArray *devices;
}

#pragma mark Methods
- (void)resizeWindowOnSpotWithSize:(NSSize)newSize;
- (IBAction)switchLayout:(id)sender;
- (NSArray *)deviceInfoList;

#pragma mark Properties
@property (assign,getter=isTracking) BOOL tracking;
@property (retain,nonatomic) MKLayout *currentLayout;
@property (retain) NSMutableArray *devices;
@property (retain,readonly) MKKeyboard *keyboard;

@end
