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
 *******************************************************************************************************************/

#import <Cocoa/Cocoa.h>

#define kMultitouchFingers 11

@class MKWindow;
@class MKLayout;
typedef struct MTDeviceX MTDeviceX;

typedef struct {
	BOOL state;
	NSImageView *tapView;
	double last;
} MKFinger;

typedef struct {
	NSUInteger dev_id;
	BOOL state;
	struct MTDeviceX *device;
	MKFinger fingers[kMultitouchFingers];
} MKDevice;

@interface MKKeyboard : NSObject {
	NSImage *tap;
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
	NSSize mtSize;
	IBOutlet NSImageView *keyboardImage;
	BOOL shift;
	BOOL lastKeyWasModifier;
	IBOutlet NSView *keyboardView;

	NSSound *tapSound;

	MKLayout *currentLayout;

	NSMutableArray *devices;
}

- (void)resizeWindowOnSpotWithSize:(NSSize)newSize;
- (void)writePrefs:(NSString *)value forKey:(NSString *)key;
- (IBAction)switchLayout:(id)sender;
- (NSArray *)deviceInfoList;

@property (retain) NSImage *tap;
@property (assign) BOOL shift;
@property (assign,getter=isTracking) BOOL tracking;
@property (retain) MKLayout *currentLayout;
@property (retain) NSMutableArray *devices;

@end
