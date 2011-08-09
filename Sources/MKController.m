/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKController.m                                                                                *
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

#import "MKController.h"
#import <FeedbackReporter/FRFeedbackReporter.h>
#import "AlphaAnimation.h"
#import "MKButton.h"
#import "MKLayout.h"
#import "MKDevice.h"
#import "MKFinger.h"
#import "MKKeycodes.h"

#pragma mark Global Variables
// FIXME: Eww, globals
id refToSelf;
dispatch_queue_t myQueue;

#pragma mark Constants
NSString * const keyNUMS      = @"NUMS";
NSString * const keyQWERTY    = @"QWERTY";
NSString * const keySYMS      = @"SYMS";
NSString * const keyMODIFIERS = @"MODIFIERS";
NSString * const keySHIFT     = @"SHIFT";
NSString * const keyCTRL      = @"CTRL";
NSString * const keyALT       = @"ALT";
NSString * const keyCMD       = @"CMD";

NSString * const kLayout      = @"layout";

NSString * const kQwertyMini  = @"QwertyMini";
NSString * const kNumPadFull  = @"NumPadFull";
NSString * const kNumsMini    = @"NumsMini";
NSString * const kSymbolsMini = @"SymbolsMini";
NSString * const kModsMini    = @"ModsMini";

NSString * const kDefaultLayout = @"QwertyMini";

const double kSamplingInterval = 0.02;

#pragma mark -
#pragma mark Interface (private)
@interface MKController ()
#pragma mark Private methods and properties

- (void)animateImage:(NSImageView *)image;
- (void)processTouch:(Touch *)touch onDevice:(MKDevice *)device;
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
#pragma mark Implementation
@implementation MKController

#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {
		tap = [[NSImage imageNamed:@"Tap.png"] retain];
		mtSize = NSMakeSize(311, 368);
		tracking = YES;
		cmd = NO;
		alt = NO;
		ctrl = NO;
		shift = NO;
		lastKeyWasModifier = NO;
		currentLayout = nil;
		keyLabels = [[NSMutableArray alloc] init];
		refToSelf = self;
		tapSound = [[NSSound soundNamed:@"Tock"] retain];
		myQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.myqueue",
						  [[NSBundle mainBundle] bundleIdentifier]] cStringUsingEncoding:
						 NSASCIIStringEncoding], 0);
		devices = [[NSMutableArray alloc] init];
		//MTDeviceRef dev = MTDeviceCreateDefault(1);
		//MTRegisterContactFrameCallback(dev, callback);
		//MTDeviceStart(dev, 0);
	}
	return self;
}

- (void)awakeFromNib {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys: kQwertyMini, kLayout, nil]];
	NSString *layout = [defaults stringForKey:kLayout];
	[selQwerty setState:0];
	[selFullNum setState:0];
	NSLog(@"Default layout is: %@", layout);
	if ([layout isEqualToString:kQwertyMini])
		[self switchLayout:selQwerty];
	else if ([layout isEqualToString:kNumPadFull])
		[self switchLayout:selFullNum];

	NSMutableArray *deviceList = (NSMutableArray *)MTDeviceCreateList(); //grab our device list
	for (NSUInteger i = 0; i < [deviceList count]; i++) {
		MKDevice *thisDevice = [MKDevice deviceWithMTDeviceRef:(MTDeviceInfo *)[deviceList objectAtIndex:i] ID:i];
#ifdef __DEBUGGING__
		NSLog(@"Checking device: %@", [thisDevice getInfo]);
#endif // __DEBUGGING__
		if (![thisDevice isValid]) {
			NSLog(@"Unrecognized device (#%lu), please report.\nDevice info: %@", i, [thisDevice getInfo]);
			if (!thisDevice)
				continue;
		}
		switch ([thisDevice family]) {
		case kDeviceFamilyMBPTrackpad:
			NSLog(@"Detected MacBook Pro trackpad (#%lu).", i);
			break;
		case kDeviceFamilyMagicMouse:
			NSLog(@"Detected Magic Mouse (#%lu).  Ignoring it.", i);
			continue;
		case kDeviceFamilyMagicTrackpad:
			NSLog(@"Detected Magic Trackpad (#%lu).", i);
			break;
		default:
			NSLog(@"Detected device (#%lu) family %d.  Ignoring it.", i, [thisDevice family]);
			NSLog(@"Device info: %@", [thisDevice getInfo]);
			continue;
		}
		[thisDevice setEnabled:YES];
		[[self devices] addObject:thisDevice];
		MTRegisterContactFrameCallback([deviceList objectAtIndex:i], callback); //assign callback for device
		MTDeviceStart([deviceList objectAtIndex:i], 0); //start sending events
	}
	CFRelease((CFMutableArrayRef)deviceList);
	if ([[self devices] count] < 1) {
		NSInteger theResponse = NSRunAlertPanel(@"No supported devices detected",
				@"We couldn't detect any compatible multitouch device connected to your system.\n"
				"If a multitouch devie is connected but not detected, please inform us, so that it'll "
				"be supported soon.\n\n"
				"Do you want to send us feedback about an incompatible device?",
				@"Send Feedback", @"Cancel", nil);
		switch (theResponse) {
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
	NSTrackingArea *trackingArea = [[[NSTrackingArea alloc]
					 initWithRect:[keyboardView frame]
					 options:NSTrackingMouseMoved|NSTrackingActiveInKeyWindow
					 owner:keyboardView userInfo:nil] autorelease];
	[keyboardView addTrackingArea:trackingArea];
	[keyboardView becomeFirstResponder];
}

- (void)dealloc {
	dispatch_release(myQueue);
	[tapSound release];
	[tap release];
	[keyLabels release];
	[currentLayout release];
	[devices release];

	[super dealloc];
}

#pragma mark Touch handling
int callback( int device, Touch *data, int nTouches, double timestamp, int frame ) {
#pragma unused (timestamp, frame)
	// This is to avoid leaks
	NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];
	for( int i = 0; i < nTouches; i++ ) {
		Touch *t = &data[i];
		MKDevice *thisDevice = nil;
		NSUInteger j = 0;
		for (j = 0; j < [[refToSelf devices] count]; j++) {
			thisDevice = (MKDevice *)[[refToSelf devices] objectAtIndex:j];
			if ([thisDevice devPtr] == device)
				break;
		}
		if (j >= [[refToSelf devices] count]) {
			NSLog(@"Device (%x) not found.  Ignoring touch.", device);
			continue;
		}
		[refToSelf processTouch:t onDevice:thisDevice];
	}
	// Time to release... or drain now.
	[thePool drain];
	return 0;
}

- (void)processTouch:(Touch *)touch onDevice:(MKDevice *)device {
	if (![self isTracking])
		return;
	if (touch->identifier > kMultitouchFingersMax || touch->identifier <= 0) // Sanity check
		return;

	NSRect imgBox = NSMakeRect((CGFloat)((mtSize.width*(touch->normalized.pos.x))*1.25),
				   (CGFloat)((mtSize.height*(touch->normalized.pos.y))*1.10),
				   33, 34);

	MKFinger *thisFinger = [[device fingers] objectAtIndex:touch->identifier-1];
	switch (touch->state) {
	case 1: // FIXME: Constants
		if ([thisFinger isActive])
			return;
		[thisFinger setLast:touch->timestamp];
		[thisFinger setActive:YES];
		NSImageView *tapView = [[[NSImageView alloc] initWithFrame:imgBox] autorelease];
		[tapView setImage:tap];
		[keyboardView addSubview:tapView];
		[thisFinger setTapView:tapView];
		return;
	case 7:
		if (![thisFinger isActive])
			return;
		[thisFinger setActive:NO];
		[thisFinger setLast:touch->timestamp];
		[[thisFinger tapView] removeFromSuperview];
		[thisFinger setTapView:nil];
		break;
	default:
		if (touch->timestamp < [thisFinger last] + kSamplingInterval)
			return;
		[thisFinger setLast:touch->timestamp];
		[[thisFinger tapView] setFrame:imgBox];
		return;
	}
	for (NSUInteger i = 0; i < [[currentLayout currentButtons] count] ; i++) {
		MKButton *button = [[currentLayout currentButtons] objectAtIndex:i];
		if (![button containsPoint:imgBox.origin size:imgBox.size])
			continue;
		if ([button isSingleKeypress]) {
			[MKKeycodes sendKeycodeForKey:[button value] type:[button type]];
			lastKeyWasModifier = NO;
		} else if ([[button value]isEqualToString:keyNUMS]) { // FIXME
			[self setCurrentLayout:[MKLayout layoutWithName:kNumsMini]];
			[keyboardImage setImage:[currentLayout keyboardImage]];
		} else if ([[button value]isEqualToString:keyQWERTY]) { // FIXME
			[self setCurrentLayout:[MKLayout layoutWithName:kQwertyMini]];
			[keyboardImage setImage:[currentLayout keyboardImage]];
		} else if ([[button value] isEqualToString:keySYMS]) { // FIXME
			[self setCurrentLayout:[MKLayout layoutWithName:kSymbolsMini]];
			[keyboardImage setImage:[currentLayout keyboardImage]];
		} else if ([[button value] isEqualToString:keyMODIFIERS]) { // FIXME
			[self setCurrentLayout:[MKLayout layoutWithName:kModsMini]];
			[keyboardImage setImage:[currentLayout keyboardImage]];
		} else {
			if ([[currentLayout layoutName] isEqualToString:@"Mini QWERTY Keyboard"]) { // FIXME: String
				if ([[button value] isEqualToString:keySHIFT]) {
					shift = !shift;
					[shiftChk setState:shift];
					lastKeyWasModifier = YES;
				}
			} else if ([[currentLayout layoutName] isEqualToString:@"Mini Numbers Keyboard"] // FIXME: Strings
				   || [[currentLayout layoutName] isEqualToString:@"Mini Symbols Keyboard"]
				   || [[currentLayout layoutName] isEqualToString:@"Mini Modifiers Keyboard"]) {
				if ([[button value] isEqualToString:keyCTRL]) {
					ctrl = !ctrl;
					[ctrlChk setState:ctrl];
					lastKeyWasModifier = YES;
				} else if ([[button value] isEqualToString:keyALT]) {
					alt = !alt;
					[altChk setState:alt];
					lastKeyWasModifier = YES;
				} else if ([[button value] isEqualToString:keyCMD]) {
					cmd = !cmd;
					[cmdChk setState:cmd];
					lastKeyWasModifier = YES;
				}
				if (!ctrl && !cmd && !alt) {
					lastKeyWasModifier = NO;
				}
			}
		}
		NSImageView *tapImageView = [[[NSImageView alloc] initWithFrame:imgBox] autorelease];
		[tapImageView setImage:tap];
		[tapSound play];
		dispatch_async(myQueue, ^{
			[self animateImage:tapImageView];
		});
		[keyboardView addSubview:tapImageView];
		tapImageView = nil;
		if (!lastKeyWasModifier) {
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
	NSRect delta = NSMakeRect(originalView.size.width - newSize.width,
				  originalView.size.height - newSize.height,
				  newSize.width - originalView.size.width,
				  newSize.height - originalView.size.height);

	NSRect newRect = NSMakeRect(originalWindow.origin.x + delta.origin.x,
				    originalWindow.origin.y + delta.origin.y,
				    originalWindow.size.width + delta.size.width,
				    originalWindow.size.height + delta.size.height);
	[window setFrame:newRect display:YES animate:YES];
}

- (IBAction)switchLayout:(id)sender {
	// FIXME: Add layouts
	if ([sender state])
		return;
	
	if (sender == selQwerty) {
		[selQwerty setState:1];
		[selFullNum setState:0];
		[self setCurrentLayout:[MKLayout layoutWithName:kQwertyMini]];
	} else if (sender == selFullNum) {
		[selQwerty setState:0];
		[selFullNum setState:1];
		[self setCurrentLayout:[MKLayout layoutWithName:kNumPadFull]];
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[[self currentLayout] layoutIdentifier] forKey:kLayout];
	[defaults synchronize];
}

- (void)setCurrentLayout:(MKLayout *)newLayout {
#ifdef __DEBUGGING__
	NSLog(@"Switching to layout: %@", [newLayout layoutName]);
#endif // __DEBUGGING__
	while ([keyLabels count] > 0) {
		NSTextField *thisLabel = [keyLabels objectAtIndex:0];
		[thisLabel removeFromSuperview];
		[keyLabels removeObject:thisLabel];
	}

	[currentLayout autorelease];
	currentLayout = [newLayout retain];
	[self resizeWindowOnSpotWithSize:[newLayout layoutSize]];
	[keyboardImage setImage:[newLayout keyboardImage]];
	
	NSArray *layoutLabels = [newLayout createLabels];
	for (NSTextField *eachLabel in layoutLabels) {
		[keyLabels addObject:eachLabel];
		[keyboardView addSubview:eachLabel];
	}
}

- (void)animateImage:(NSImageView *)imageView {
	AlphaAnimation *animation = [[[AlphaAnimation alloc] initWithDuration:0.2 effect:AAFadeOut object:imageView]
				     autorelease];
	[animation setAnimationBlockingMode:NSAnimationBlocking];
	[animation startAnimation];
	[imageView removeFromSuperview];
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

#pragma mark Utilities
- (NSArray *)deviceInfoList {
	NSMutableArray *devs = [NSMutableArray array];
	for (MKDevice *eachDevice in [self devices]) {
		NSDictionary *thisDeviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithBool:[eachDevice isEnabled]], @"State",
						[eachDevice getInfo], @"Info",
						nil];
		[devs addObject:thisDeviceInfo];
	}
	return devs;
}

#pragma mark -
#pragma mark Properties
@synthesize tracking;
@synthesize currentLayout;
@synthesize devices;

@end
