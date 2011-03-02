/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKKeyboard.h                                                                                  *
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

@class MKButton;
@class MKWindow;

@interface MKKeyboard : NSObject <NSXMLParserDelegate> {
	NSImage *tap;
	NSImage *qwertyLayout;
	NSImage *fullNumLayout;
	NSImage *modsLayout;
	NSImage *numbersLayout;
	NSImage *currentLayout;
	NSImage *symsLayout;
	IBOutlet MKWindow *window;
	IBOutlet NSButton *shiftChk;
	IBOutlet NSButton *cmdChk;
	IBOutlet NSButton *ctrlChk;
	IBOutlet NSButton *altChk;
	NSMutableDictionary *prefs;

	IBOutlet NSMenuItem *selQwerty;
	IBOutlet NSMenuItem *selFullNum;
	BOOL cmd;
	BOOL alt;
	BOOL ctrl;
	BOOL tracking;
	NSMutableArray *currentButtons;
	NSSize mtSize;
	IBOutlet NSImageView *keyboardImage;
	BOOL shift;
	BOOL lastKeyWasModifier;
	IBOutlet NSView *keyboardView;
	
	NSSound *tapSound;
}

- (void)resizeWindowOnSpotWithSize:(NSSize)newSize;
- (void)writePrefs:(NSString *)value forKey:(NSString *)key;
- (IBAction)switchLayout:(id)sender;
- (void)getButtonsForXMLFile:(NSString *)fileName;

@property (retain) NSImage *qwertyLayout;
@property (retain) NSImage *symsLayout;
@property (retain) NSImage *numbersLayout;
@property (retain) NSImage *tap;
@property (retain) NSMutableArray *currentButtons;
@property (assign) BOOL shift;
@property (assign,getter=isTracking) BOOL tracking;

@end
