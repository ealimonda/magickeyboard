/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKKeyboard.m                                                                                  *
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

#import "MKKeyboard.h"
#import "AlphaAnimation.h"
#import "MKButton.h"
#import "MKLayout.h"

#pragma mark Global Variables
// FIXME: Eww, globals
id refToSelf;
dispatch_queue_t myQueue;

#pragma mark Constants
NSString * const keyNUMS = @"NUMS";
NSString * const keyQWERTY = @"QWERTY";
NSString * const keySYMS = @"SYMS";
NSString * const keyMODIFIERS = @"MODIFIERS";
NSString * const keySHIFT = @"SHIFT";
NSString * const keyCTRL = @"CTRL";
NSString * const keyALT = @"ALT";
NSString * const keyCMD = @"CMD";

NSString * const kLayout = @"layout";

NSString * const kQwertyMini = @"QwertyMini";
NSString * const kNumPadFull = @"NumPadFull";
NSString * const kNumsMini = @"NumsMini";
NSString * const kSymbolsMini = @"SymbolsMini";
NSString * const kModsMini = @"ModsMini";

NSString * const kPreferencesFolder = @"~/Library/Preferences";

NSString * const kDefaultLayout = @"QwertyMini";

#pragma mark -
@interface MKKeyboard ()
#pragma mark Private methods and properties
typedef struct {
	float x,y;
} mtPoint;

typedef struct {
	mtPoint pos,vel;
} mtReadout;

typedef struct {
	int frame;
	double timestamp;
	int identifier, state, foo3, foo4;
	mtReadout normalized;
	float size;
	int zero1;
	float angle, majorAxis, minorAxis; // ellipsoid
	mtReadout mm;
	int zero2[2];
	float unk2;
} Finger;

typedef struct {
	uint32 unk_v0; // C8 B3 76 70  on both Mouse and Trackpad, but changes on other computers (i.e.: C8 23 FC 70)
	uint32 unk_k0; // FF 7F 00 00
	uint32 unk_k1; // 80 0E 01 00, then it changed to 80 10 01 00.  What is this?
	uint32 unk_k2; // 01 00 00 00
	uint32 unk_v1; // 0F 35 00 00, 03 76 00 00, 03 6E 00 00 / 03 37 00 00, 03 77 00 00
	uint32 unk_k3; // 00 00 00 00
	uint32 unk_v2; // 24 50 40 62, 92 2E D0 1E / 40 D8 FD 5E
	uint32 unk_k4; // 00 00 00 04
	uint32 family; // 70 00 00 00 / 80 00 00 00
	uint32 unk_v3; // 23 01 00 00 / 49 01 00 00
	uint32 rows; // 0F 00 00 00 / 14 00 00 00
	uint32 cols; // 0A 00 00 00 / 18 00 00 00
	uint32 unk_v4; // 20 14 00 00 / C8 32 00 00
	uint32 unk_v5; // 60 23 00 00 / F8 2A 00 00
	uint32 unk_k5; // 01 00 00 00
	uint32 unk_k6; // 00 00 00 00
	uint32 unk_v6; // 90 04 75 70, 90 74 FA 70
	uint32 unk_k7; // FF 7F 00 00
} MTDeviceX;

const MTDeviceX multiTouchSampleDevice = {
	0x0,
	0x00007FFF,
	0x00011080,
	0x00000001,
	0x0,
	0x00000000,
	0x0,
	0x04000000,
	0x0,
	0x0,
	0x0,
	0x0,
	0x0,
	0x0,
	0x00000001,
	0x00000000,
	0x0,
	0x00007FFF,
};

- (void)sendKeycode:(CGKeyCode)keycode;
- (void)animateImage:(NSImageView *)image;
- (void)processTouch:(Finger *)f;
typedef void *MTDeviceRef;
typedef int (*MTContactCallbackFunction)(int, Finger *, int, double, int);

int callback( int device, Finger *data, int nFingers, double timestamp, int frame );

#pragma mark Apple Private Frameworks
MTDeviceRef MTDeviceCreateDefault();
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTDeviceStart(MTDeviceRef, int); // thanks comex
CFMutableArrayRef MTDeviceCreateList(void); //returns a CFMutableArrayRef array of all multitouch devices

@end

#pragma mark -
@implementation MKKeyboard
#pragma mark Initialization

+ (NSString *)getInfoForDevice:(MTDeviceX *)device {
	if( !device )
		return @"nil";
	return [NSString stringWithFormat:@"MultiTouchDevice: {\n"
			"\tunk_v0 = %08x\n"
			"\tunk_k0 = %08x\n"
			"\tunk_k1 = %08x\n"
			"\tunk_k2 = %08x\n"
			"\tunk_v1 = %08x\n"
			"\tunk_k3 = %08x\n"
			"\tunk_v2 = %08x\n"
			"\tunk_k4 = %08x\n"
			"\tfamily = %08x\n"
			"\tunk_v3 = %08x\n"
			"\trows   = %08x\n"
			"\tcols   = %08x\n"
			"\tunk_v4 = %08x\n"
			"\tunk_v5 = %08x\n"
			"\tunk_k5 = %08x\n"
			"\tunk_k6 = %08x\n"
			"\tunk_v6 = %08x\n"
			"\tunk_k7 = %08x\n"
			"}",
			device->unk_v0,
			device->unk_k0,
			device->unk_k1,
			device->unk_k2,
			device->unk_v1,
			device->unk_k3,
			device->unk_v2,
			device->unk_k4,
			device->family,
			device->unk_v3,
			device->rows,
			device->cols,
			device->unk_v4,
			device->unk_v5,
			device->unk_k5,
			device->unk_k6,
			device->unk_v6,
			device->unk_k7
	];
}

- (id)init {
	self = [super init];
	if( self ) {
		tap = [[NSImage imageNamed:@"Tap.png"] retain];
		mtSize = NSZeroSize;
		mtSize.height = 311;
		mtSize.width = 368;
		tracking = YES;
		cmd = NO;
		alt = NO;
		ctrl = NO;
		shift = NO;
		lastKeyWasModifier = NO;
		currentLayout = [[MKLayout layoutWithName:kDefaultLayout] retain];
		refToSelf = self;
		tapSound = [[NSSound soundNamed:@"Tock"] retain];
		myQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.myqueue", [[NSBundle mainBundle]
				bundleIdentifier]] cStringUsingEncoding:NSASCIIStringEncoding], 0);
		//MTDeviceRef dev = MTDeviceCreateDefault(1);
		//MTRegisterContactFrameCallback(dev, callback);
		//MTDeviceStart(dev, 0);
		
		// if the file was there, we got all the informati
		// FIXME: use CFPreferences / NSUserDefaults
		prefs = [[NSDictionary alloc] initWithContentsOfFile:[[kPreferencesFolder
				stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]]
				stringByExpandingTildeInPath]];
		if( prefs ) {
			NSString *layout = [prefs objectForKey:kLayout];
			[selQwerty setState:0];
			[selFullNum setState:0];
			if( [layout isEqualToString:kQwertyMini] )
				[self switchLayout:selQwerty];
			else if( [layout isEqualToString:kNumPadFull] )
				[self switchLayout:selFullNum];
		} else {
			prefs = [[NSMutableDictionary alloc] init];
			[self writePrefs:kQwertyMini forKey:kLayout];
		}
	}
	return self;
}

- (void)awakeFromNib {
	NSMutableArray *deviceList = (NSMutableArray *)MTDeviceCreateList(); //grab our device list
	for( NSUInteger i = 0; i < [deviceList count]; i++) {
		MTDeviceX *thisDevice = (MTDeviceX*)[deviceList objectAtIndex:i];
#ifdef __DEBUGGING__
		NSLog(@"Checking device: %@", [[self class] getInfoForDevice:thisDevice]);
#endif
		if( !thisDevice
		   		|| thisDevice->unk_k0 != multiTouchSampleDevice.unk_k0
				|| thisDevice->unk_k1 != multiTouchSampleDevice.unk_k1
				|| thisDevice->unk_k2 != multiTouchSampleDevice.unk_k2
				|| thisDevice->unk_k3 != multiTouchSampleDevice.unk_k3
				|| thisDevice->unk_k4 != multiTouchSampleDevice.unk_k4
				|| thisDevice->unk_k5 != multiTouchSampleDevice.unk_k5
				|| thisDevice->unk_k6 != multiTouchSampleDevice.unk_k6
				|| thisDevice->unk_k7 != multiTouchSampleDevice.unk_k7
				) {
			NSLog(@"Unrecognized device (#%d), please report.\nDevice info: %@", i, [[self class]
					getInfoForDevice:thisDevice]);
			if( !thisDevice )
				continue;
		}
		switch( thisDevice->family ) {
		case 0x00000070:
			NSLog(@"Detected Magic Mouse (#%d).  Ignoring it.", i);
			continue;
		case 0x00000080:
			NSLog(@"Detected Magic Trackpad (#%d).", i);
			break;
		default:
			NSLog(@"Detected device (#%d) family %d.  Ignoring it.", i, thisDevice->family);
			NSLog(@"Device info: %@", [[self class] getInfoForDevice:thisDevice]);
			continue;
		}
		MTRegisterContactFrameCallback([deviceList objectAtIndex:i], callback); //assign callback for device
		MTDeviceStart([deviceList objectAtIndex:i], 0); //start sending events
	}
	CFRelease((CFMutableArrayRef)deviceList);
		
	[keyboardView setAcceptsTouchEvents:NO];
	NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:[keyboardView frame]
			options:NSTrackingMouseMoved|NSTrackingActiveInKeyWindow owner:keyboardView userInfo:nil] autorelease];
	[keyboardView addTrackingArea:trackingArea];
	[keyboardView becomeFirstResponder];
}

- (void)dealloc {
	dispatch_release(myQueue);
	[tapSound release];
	[tap release];
	[currentLayout release];
	[prefs release];
	[super dealloc];
}

#pragma mark Touch handling

int callback( int device, Finger *data, int nFingers, double timestamp, int frame ) {
#pragma unused (device, timestamp, frame)
#if 0
	for (int i=0; i<nFingers; i++) {
		Finger *f = &data[i];
	}
#endif // 0
	// This is to avoid leaks
	NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];
	if( nFingers == 1 ) {
		Finger *f = &data[0];
		[refToSelf processTouch:f];
	}
	// Time to release... or drain now.
	[thePool drain];
	return 0;
}

- (void)processTouch:(Finger *)finger {
	if( finger->state != 7 || ![self isTracking] )
		return;
#if 0
	NSLog([NSString stringWithFormat:@"Frame %7d: Angle %6.2f, ellipse %6.3f x%6.3f; "
			"position (%6.3f,%6.3f) vel (%6.3f,%6.3f) "
			"ID %d, state %d [%d %d?] size %6.3f, %6.3f?",
			finger->frame,
			finger->angle * 90 / atan2(1,0),
			finger->majorAxis,
			finger->minorAxis,
			finger->normalized.pos.x,
			finger->normalized.pos.y,
			finger->normalized.vel.x,
			finger->normalized.vel.y,
			finger->identifier, finger->state, finger->foo3, finger->foo4,
			finger->size, finger->unk2]);
#endif // 0
	NSRect imgBox;
	NSPoint aPoint = NSMakePoint((CGFloat)((mtSize.width*(finger->normalized.pos.x))*1.25),
			(CGFloat)((mtSize.height*(finger->normalized.pos.y))*1.10));
	imgBox.origin.x = aPoint.x;
	imgBox.origin.y = aPoint.y;
	//NSLog([NSString stringWithFormat:@"%f",aPoint.x]);
	//NSLog([NSString stringWithFormat:@"%f",aPoint.y]);
	imgBox.size.width=33;
	imgBox.size.height=34;
	for( NSUInteger i = 0; i < [[currentLayout currentButtons] count] ; i++ ) {
		MKButton *button = [[currentLayout currentButtons] objectAtIndex:i];
		if( ![button containsPoint:aPoint size:imgBox.size] )
			continue;
		//NSLog([button letter]);
		BOOL doSend = YES;
		int keycode = 0;
		if( [[button letter]isEqualToString:keyNUMS] ) {
			[self setCurrentLayout:[MKLayout layoutWithName:kNumsMini]];
			[keyboardImage setImage:[currentLayout keyboardImage]];
			doSend = NO;
		} else if( [[button letter]isEqualToString:keyQWERTY] ) {
			[self setCurrentLayout:[MKLayout layoutWithName:kQwertyMini]];
			[keyboardImage setImage:[currentLayout keyboardImage]];
			doSend = NO;
		} else if( [[button letter] isEqualToString:keySYMS] ) {
			[self setCurrentLayout:[MKLayout layoutWithName:kSymbolsMini]];
			[keyboardImage setImage:[currentLayout keyboardImage]];
			doSend = NO;
		} else if( [[button letter] isEqualToString:keyMODIFIERS] ) {
			[self setCurrentLayout:[MKLayout layoutWithName:kModsMini]];
			[keyboardImage setImage:[currentLayout keyboardImage]];
			doSend = NO;
		} else {
			if( [[currentLayout layoutName] isEqualToString:@"Mini QWERTY Keyboard"] ) { // FIXME: String
				if( [[button letter] isEqualToString:keySHIFT] ) {
					shift = !shift;
					[shiftChk setState:shift];
					doSend = NO;
					lastKeyWasModifier = YES;
				} else {
					keycode = (CGKeyCode)[[button keycode] integerValue];
					lastKeyWasModifier = NO;
				}
			} else if( [[currentLayout layoutName] isEqualToString:@"Mini Numbers Keyboard"] // FIXME: Strings
					|| [[currentLayout layoutName] isEqualToString:@"Mini Symbols Keyboard"]
					|| [[currentLayout layoutName] isEqualToString:@"Mini Modifiers Keyboard"] ) {
				if( [[button letter] isEqualToString:keyCTRL] ) {
					ctrl = !ctrl;
					[ctrlChk setState:ctrl];
					doSend = NO;
					lastKeyWasModifier = YES;
				} else if( [[button letter] isEqualToString:keyALT] ) {
					alt = !alt;
					doSend = NO;
					[altChk setState:alt];
					lastKeyWasModifier = YES;
				} else if( [[button letter] isEqualToString:keyCMD] ) {
					cmd = !cmd;
					[cmdChk setState:cmd];
					doSend = NO;
					lastKeyWasModifier = YES;
				} else {
					lastKeyWasModifier = NO;
				}
				if( !ctrl && !cmd && !alt ) {
					lastKeyWasModifier = NO;
				}
				if( [[button keycode] characterAtIndex:0] == 'S' ) {
					// FIXME: Ugly
					keycode = (CGKeyCode)[[[button keycode]
							stringByReplacingOccurrencesOfString:@"S"
							withString:@""] integerValue];
					keycode += 300;
				} else {
					keycode = (CGKeyCode)[[button keycode] integerValue];
				}
			} else if( [[currentLayout layoutName] isEqualToString:@"Full Numeric Keypad"] ) { // FIXME: String
				lastKeyWasModifier = NO;
				keycode = (CGKeyCode)[[button keycode] integerValue];
			}
		}
		if( doSend ) {
			[self sendKeycode:keycode];
		}
		NSImageView *tapImageView = [[[NSImageView alloc] initWithFrame:imgBox] autorelease];
		[tapImageView setImage:tap];
		[tapSound play];
		dispatch_async(myQueue, ^{
			[self animateImage:tapImageView];
		});
		[keyboardView addSubview:tapImageView];
		tapImageView = nil;
		if( !lastKeyWasModifier ) {
			cmd = NO;
			[cmdChk setState:0];
			alt = NO;
			[altChk setState:0];
			ctrl = NO;
			[ctrlChk setState:0];
		}
	}
}

- (void)sendKeycode:(CGKeyCode)keycode {
	// TODO: http://stackoverflow.com/questions/1918841/how-to-convert-ascii-character-to-cgkeycode
	BOOL needsShift = keycode >= 300;
	long flags = 0;
	if( needsShift ){
		keycode -= 300;
	}
	if( shift || needsShift ) {
		flags |= kCGEventFlagMaskShift;
	}	
	if( cmd ) {
		flags |= kCGEventFlagMaskCommand;
	}
	if( alt ) {
		flags |= kCGEventFlagMaskAlternate;
	}
	if( ctrl ) {
		flags |= kCGEventFlagMaskControl;
	}
	//NSLog([NSString stringWithFormat:@"%d",keycode]);
	CGEventRef event1, event2;
	event1 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, YES); //'z' keydown event
	event2 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, NO);
	if( flags > 0 ) {
		CGEventSetFlags(event1, flags);//set shift key down for above event
		CGEventSetFlags(event2, flags);//set shift key down for above event
	} else {
		CGEventSetFlags(event1, 0);//set shift key down for above event
		CGEventSetFlags(event2, 0);//set shift key down for above event
	}
	CGEventPost(kCGHIDEventTap, event1);//post event
	CFRelease(event1);
	usleep(50);
	CGEventPost(kCGHIDEventTap, event2);//post event
	CFRelease(event2);
	usleep(50);
	if( shift || needsShift ) {
		CGEventRef shiftUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)56, NO);//'z' keydown event
		CGEventPost(kCGHIDEventTap, shiftUp);//post event
		CFRelease(shiftUp);
		usleep(50);
	}
	if( cmd ) {
		CGEventRef cmdUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)55, NO);//'z' keydown event
		CGEventPost(kCGHIDEventTap, cmdUp);//post event
		CFRelease(cmdUp);
		usleep(50);
	}
	if( alt ) {
		CGEventRef altUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)58, NO);//'z' keydown event
		CGEventPost(kCGHIDEventTap, altUp);//post event
		CFRelease(altUp);
		usleep(50);
	}
	if( ctrl ) {
		CGEventRef ctrlUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)59, NO);//'z' keydown event
		CGEventPost(kCGHIDEventTap, ctrlUp);//post event
		CFRelease(ctrlUp);
		usleep(50);
	}
}

#pragma mark Preferences
- (void) writePrefs:(NSString *)value forKey:(NSString *)key {
	[prefs setObject:value forKey:key];
	// FIXME: Use CFPreferences / NSUserDefaults
	[prefs writeToFile:[[kPreferencesFolder stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]]
			stringByExpandingTildeInPath] atomically:YES];
}

#pragma mark window and layout
#if 0 // Unused
+ (CGFloat)titleBarHeight {
	NSRect frame = NSMakeRect (0, 0, 100, 100);
	NSRect contentRect = [NSWindow contentRectForFrameRect:frame styleMask:NSTitledWindowMask];

	return (frame.size.height - contentRect.size.height - contentRect.origin.y);
}
#endif // 0

- (void)resizeWindowOnSpotWithSize:(NSSize)newSize {
	NSRect originalWindow = [window frame];
	NSRect originalView = [keyboardImage frame];
	NSRect delta = NSMakeRect(originalView.size.width - newSize.width, originalView.size.height - newSize.height,
			newSize.width - originalView.size.width, newSize.height - originalView.size.height);

	NSRect newRect = NSMakeRect(originalWindow.origin.x + delta.origin.x, originalWindow.origin.y + delta.origin.y,
			originalWindow.size.width + delta.size.width, originalWindow.size.height + delta.size.height);
	[window setFrame:newRect display:YES animate:YES];
}

- (IBAction)switchLayout:(id)sender {
	if( [sender state] )
		return;
	
	if( sender == selQwerty ) {
		[selQwerty setState:1];
		[selFullNum setState:0];
		[self writePrefs:kQwertyMini forKey:kLayout];
		[self setCurrentLayout:[MKLayout layoutWithName:kQwertyMini]];
		[self resizeWindowOnSpotWithSize:[[self currentLayout] layoutSize]];
		[keyboardImage setImage:[[self currentLayout] keyboardImage]];
	} else if( sender == selFullNum ) {
		[selQwerty setState:0];
		[selFullNum setState:1];
		[self writePrefs:kNumPadFull forKey:kLayout];
		[self setCurrentLayout:[MKLayout layoutWithName:kNumPadFull]];
		[self resizeWindowOnSpotWithSize:[[self currentLayout] layoutSize]];
		[keyboardImage setImage:[[self currentLayout] keyboardImage]];
	}
}

- (void)animateImage:(NSImageView *)imageView {
	AlphaAnimation *animation = [[[AlphaAnimation alloc] initWithDuration:0.2 effect:AAFadeOut object:imageView] autorelease];
	[animation setAnimationBlockingMode:NSAnimationBlocking];
	[animation startAnimation];
	[imageView removeFromSuperview];
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

#pragma mark -
#pragma mark Properties
@synthesize tap;
@synthesize shift;
@synthesize tracking;
@synthesize currentLayout;

@end
