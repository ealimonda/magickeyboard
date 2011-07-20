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
 *******************************************************************************************************************/

#import "MKKeyboard.h"
#import <FeedbackReporter/FRFeedbackReporter.h>
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

const double kSamplingInterval = 0.02;

#pragma mark -
@interface MKKeyboard ()
#pragma mark Private methods and properties
typedef struct {
	float x, y;
} mtPoint;

typedef struct {
	mtPoint pos, vel;
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
} Touch;

struct MTDeviceX {
	uint32 unk_v0; // C8 B3 76 70  on both Mouse and Trackpad, but changes on other computers (i.e.: C8 23 FC 70)
	uint32 unk_k0; // FF 7F 00 00
	uint32 unk_v1; // 80 0E 01 00, then it changed to 80 10 01 00.  What is this?
	uint32 unk_k1; // 01 00 00 00 - Could be Endianness
	uint32 unk_v2; // 0F 35 00 00, 03 76 00 00, 03 6E 00 00 / 03 37 00 00, 03 77 00 00
	uint32 unk_k2; // 00 00 00 00
	uint32 address; // Last 4 bytes of the device address (or serial number?), as reported by the System Profiler Bluetooth tab
	uint32 unk_v3; // 00 00 00 04, some times 00 00 00 03 - Last byte might be Parser Options?
		// (uint64)address = Multitouch ID
	uint32 family; // Family ID
	uint32 bcdver; // bcdVersion
	uint32 rows; // Sensor Rows
	uint32 cols; // Sensor Columns
	uint32 width; // Sensor Surface Width
	uint32 height; // Sensor Surface Height
	uint32 unk_k3; // 01 00 00 00 - Could be Endianness
	uint32 unk_k4; // 00 00 00 00
	uint32 unk_v4; // 90 04 75 70, 90 74 FA 70
	uint32 unk_k5; // FF 7F 00 00
};

const MTDeviceX multiTouchSampleDevice = {
	0x0,
	0x00007FFF,
	0x0,
	0x00000001,
	0x0,
	0x00000000,
	0x0,
	0x0,
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
- (void)processTouch:(Touch *)touch onDevice:(MKDevice *)deviceInfo;
typedef void *MTDeviceRef;
typedef int (*MTContactCallbackFunction)(int, Touch *, int, double, int);

int callback( int device, Touch *data, int nTouches, double timestamp, int frame );

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
			"\t unk_v0 = %08x\n"
			"\t unk_k0 = %08x\n"
			"\t unk_v1 = %08x\n"
			"\t unk_k1 = %08x\n"
			"\t unk_v2 = %08x\n"
			"\t unk_k2 = %08x\n"
			"\taddress= %08x\n"
			"\t unk_v3 = %08x\n"
			"\tfamily = %08x\n"
			"\tbcdver = %08x\n"
			"\trows   = %08x\n"
			"\tcols   = %08x\n"
			"\twidth  = %08x\n"
			"\theight = %08x\n"
			"\t unk_k3 = %08x\n"
			"\t unk_k4 = %08x\n"
			"\t unk_v4 = %08x\n"
			"\t unk_k5 = %08x\n"
			"}",
			device->unk_v0,
			device->unk_k0,
			device->unk_v1,
			device->unk_k1,
			device->unk_v2,
			device->unk_k2,
			device->address,
			device->unk_v3,
			device->family,
			device->bcdver,
			device->rows,
			device->cols,
			device->width,
			device->height,
			device->unk_k3,
			device->unk_k4,
			device->unk_v4,
			device->unk_k5
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
		devices = [[NSMutableArray alloc] init];
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
		MTDeviceX *thisDevice = (MTDeviceX *)[deviceList objectAtIndex:i];
		NSMutableData *mkDeviceData = [NSMutableData dataWithLength:sizeof(MKDevice)];
		MKDevice *mkDeviceInfo = [mkDeviceData mutableBytes];
		mkDeviceInfo->dev_id = i;
		mkDeviceInfo->state = NO;
		mkDeviceInfo->device = thisDevice;
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
				) {
			NSLog(@"Unrecognized device (#%d), please report.\nDevice info: %@", i, [[self class]
					getInfoForDevice:thisDevice]);
			if( !thisDevice )
				continue;
		}
		switch( thisDevice->family ) {
		case 0x00000062:
			NSLog(@"Detected MacBook (Pro?) trackpad (#%d).", i);
			continue;
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
		mkDeviceInfo->state = YES;
		[[self devices] addObject:mkDeviceData];
		MTRegisterContactFrameCallback([deviceList objectAtIndex:i], callback); //assign callback for device
		MTDeviceStart([deviceList objectAtIndex:i], 0); //start sending events
	}
	CFRelease((CFMutableArrayRef)deviceList);
	if( [[self devices] count] < 1 ) {
		NSInteger theResponse = NSRunAlertPanel(@"No supported devices detected",
				@"We couldn't detect any compatible multitouch device connected to your system.\n"
				"If a multitouch devie is connected but not detected, please inform us, so that it'll "
				"be supported soon.\n\n"
				"Do you want to send us feedback about an incompatible device?",
				@"Send Feedback", @"Cancel", nil);
		switch( theResponse ) {
		case NSAlertDefaultReturn:    /* "Send Feedback" */
			[[FRFeedbackReporter sharedReporter] reportFeedback];
			break;
		case NSAlertAlternateReturn:  /* "Cancel" */
			break;
		case NSAlertErrorReturn:      /* an error occurred */
			break;
		}
	}
		
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
	[devices release];
	[prefs release];
	[super dealloc];
}

#pragma mark Touch handling

int callback( int device, Touch *data, int nTouches, double timestamp, int frame ) {
#pragma unused (device, timestamp, frame)
	// This is to avoid leaks
	NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];
	for (int i = 0; i < nTouches; i++) {
		Touch *t = &data[i];
		MKDevice *thisDevice = nil;
		NSUInteger j = 0;
		for( j = 0; j < [[refToSelf devices] count]; j++ ) {
			thisDevice = (MKDevice *)[[[refToSelf devices] objectAtIndex:j] mutableBytes];
			if( (int)(long)(thisDevice->device) == device )
				break;
		}
		if( j >= [[refToSelf devices] count] ) {
			NSLog(@"Device (%x) not found.  Ignoring touch.", device);
			continue;
		}
		[refToSelf processTouch:t onDevice:thisDevice];
	}
	// Time to release... or drain now.
	[thePool drain];
	return 0;
}

- (void)processTouch:(Touch *)touch onDevice:(MKDevice *)deviceInfo {
	if( /*(touch->state != 7 && touch->state != 1) ||*/ ![self isTracking] )
		return;
	if( touch->identifier > kMultitouchFingers || touch->identifier <= 0 ) // Sanity check
		return;
#if 0
	NSLog(@"Frame %7d: TS:%6.3f ID:%d St:%d foo3:%d foo4:%d norm.pos: [%6.3f,%6.3f] sz: %6.3f unk2:%6.3f\n",
		touch->frame, touch->timestamp, touch->identifier, touch->state, touch->foo3, touch->foo4,
		touch->normalized.pos.x, touch->normalized.pos.y, touch->size, touch->unk2);
#endif // 0
#if 0
	NSLog([NSString stringWithFormat:@"Frame %7d: Angle %6.2f, ellipse %6.3f x%6.3f; "
			"position (%6.3f,%6.3f) vel (%6.3f,%6.3f) "
			"ID %d, state %d [%d %d?] size %6.3f, %6.3f?",
			touch->frame,
			touch->angle * 90 / atan2(1,0),
			touch->majorAxis,
			touch->minorAxis,
			touch->normalized.pos.x,
			touch->normalized.pos.y,
			touch->normalized.vel.x,
			touch->normalized.vel.y,
			touch->identifier, touch->state, touch->foo3, touch->foo4,
			touch->size, touch->unk2]);
#endif // 0

	NSRect imgBox = NSMakeRect((CGFloat)((mtSize.width*(touch->normalized.pos.x))*1.25),
			(CGFloat)((mtSize.height*(touch->normalized.pos.y))*1.10),
			33, 34);

	switch( touch->state ) {
	case 1: // FIXME: Constants
		if( deviceInfo->fingers[touch->identifier-1].state )
			return;
		deviceInfo->fingers[touch->identifier-1].last = touch->timestamp;
		deviceInfo->fingers[touch->identifier-1].state = YES;
		deviceInfo->fingers[touch->identifier-1].tapView = [[NSImageView alloc] initWithFrame:imgBox];
		[deviceInfo->fingers[touch->identifier-1].tapView setImage:tap];
		[keyboardView addSubview:deviceInfo->fingers[touch->identifier-1].tapView];
		return;
	case 7:
		if( !deviceInfo->fingers[touch->identifier-1].state )
			return;
		deviceInfo->fingers[touch->identifier-1].state = NO;
		deviceInfo->fingers[touch->identifier-1].last = touch->timestamp;
		[deviceInfo->fingers[touch->identifier-1].tapView removeFromSuperview];
		[deviceInfo->fingers[touch->identifier-1].tapView autorelease];
		deviceInfo->fingers[touch->identifier-1].tapView = nil;
		break;
	default:
		if( touch->timestamp < deviceInfo->fingers[touch->identifier-1].last + kSamplingInterval )
			return;
		deviceInfo->fingers[touch->identifier-1].last = touch->timestamp;
		[deviceInfo->fingers[touch->identifier-1].tapView setFrame:imgBox];
		return;
	}
	for( NSUInteger i = 0; i < [[currentLayout currentButtons] count] ; i++ ) {
		MKButton *button = [[currentLayout currentButtons] objectAtIndex:i];
		if( ![button containsPoint:imgBox.origin size:imgBox.size] )
			continue;
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
		break;
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

- (NSArray *)deviceInfoList {
	NSMutableArray *devs = [NSMutableArray array];
	for( NSMutableData *eachDeviceData in [self devices] ) {
		MKDevice *eachDevice = [eachDeviceData mutableBytes];
		NSDictionary *thisDeviceInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
				[NSNumber numberWithBool:eachDevice->state],
				[[self class] getInfoForDevice:eachDevice->device], nil]
				forKeys:[NSArray arrayWithObjects:@"State", @"Info", nil]];
		[devs addObject:thisDeviceInfo];
	}
	return devs;
}

#pragma mark -
#pragma mark Properties
@synthesize tap;
@synthesize shift;
@synthesize tracking;
@synthesize currentLayout;
@synthesize devices;

@end
