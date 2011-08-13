/*******************************************************************************************************************
 *                                     MagicKeyboard :: MagicKeyboardAppDelegate                                   *
 *******************************************************************************************************************
 * File:             MagicKeyboardAppDelegate.m                                                                    *
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

#import "MagicKeyboardAppDelegate.h"
#import <FeedbackReporter/FRFeedbackReporter.h>
#import <ShortcutRecorder/ShortcutRecorder.h>
#import "MKPreferencesController.h"

#pragma mark Implementation
@implementation MagicKeyboardAppDelegate
OSStatus MKHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);

#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {
		statusBarItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	}
	return self;
}

- (void)dealloc {
	[prefsController release];
	[statusBarItem release];
	[super dealloc];
}

#pragma mark NSApplicationDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
#pragma unused (aNotification)
	[[FRFeedbackReporter sharedReporter] setDelegate:self];
	[window setAcceptsMouseMovedEvents:NO];
	//CGDisplayHideCursor(kCGDirectMainDisplay);
	//CGAssociateMouseAndMouseCursorPosition(NO);
	[window setLevel:NSFloatingWindowLevel];
	[window setCollectionBehavior:NSWindowCollectionBehaviorStationary];
	[statusBarItem setImage:[NSImage imageNamed:@"MagicKeyboardMenu.png"]];
	[statusBarItem setAlternateImage:[NSImage imageNamed:@"MagicKeyboardMenuAlt.png"]];
	[statusBarItem setHighlightMode:YES];
	[statusBarItem setMenu:statusMenu];
	[[FRFeedbackReporter sharedReporter] reportIfCrash];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	KeyCombo globalShortcut = {0, 0};
	globalShortcut.code = [defaults integerForKey:@"ShortcutKey"];
	globalShortcut.flags = SRCocoaToCarbonFlags([[defaults valueForKey:@"ShortcutFlags"] unsignedIntValue]);
	
	//Register the Hotkeys
	EventHotKeyRef gMyHotKeyRef;
	EventHotKeyID gMyHotKeyID;
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	InstallApplicationEventHandler(&MKHotKeyHandler, 1, &eventType, self, NULL);
	gMyHotKeyID.signature='htk1';
	gMyHotKeyID.id = 1;
	RegisterEventHotKey(0, (UInt32)globalShortcut.flags, gMyHotKeyID,
			    GetApplicationEventTarget(), 0, &gMyHotKeyRef);
}

- (IBAction)quitSelector:(id)sender {
#pragma unused (sender)
	[[NSApplication sharedApplication] terminate:self];
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

#if 0 // Disabeld because for some not better known reason it'll terminate the app after [window orderOut:(id)]
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
#pragma unused (theApplication)
	return YES;
}
#endif // 0

#pragma mark FRFeedbackReportDelegate
- (IBAction)submitFeedback:(id)sender {
#pragma unused (sender)
	[[FRFeedbackReporter sharedReporter] reportFeedback];
}

- (NSDictionary *)customParametersForFeedbackReport {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:@"None found" forKey:@"Devices"];

	if (magicKeyboardController)
		[dict setObject:[magicKeyboardController deviceInfoList] forKey:@"Devices"];
	return dict;
}

#pragma mark Preferences
- (IBAction)showPreferences:(id)sender {
#pragma unused (sender)
	if (!prefsController)
		prefsController = [[MKPreferencesController alloc] init];
	[prefsController showWindow:self];
}

#pragma mark Hotkeys
OSStatus MKHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
#pragma unused (nextHandler, theEvent, userData)
	MagicKeyboardAppDelegate *appDelegate = (MagicKeyboardAppDelegate *)userData;
	[appDelegate toggleTrackingSelector];
	return noErr;
}

- (void)toggleTrackingSelector {
	[self disableTrackingSelector:disableTrackingMenuItem];
}

#pragma Actions
- (IBAction)disableTrackingSelector:(id)sender {
	[((NSMenuItem *)sender) setState:!((BOOL)[sender state])];
	
	if ([sender state]) {
		[window orderOut:self];
		[statusBarItem setImage:[NSImage imageNamed:@"MagicKeyboardMenuDis.png"]];
	} else {
		[window makeKeyAndOrderFront:self];
		[statusBarItem setImage:[NSImage imageNamed:@"MagicKeyboardMenu.png"]];
	}
	
	[magicKeyboardController setTracking:![sender state]];
}

#pragma mark Properties
- (MKController *)controller {
	return magicKeyboardController;
}

@end
