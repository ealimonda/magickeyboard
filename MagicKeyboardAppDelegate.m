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
 *******************************************************************************************************************
 * $Id::                                                                               $: SVN Info                 *
 * $Date::                                                                             $: Last modification        *
 * $Author::                                                                           $: Last modification author *
 * $Revision::                                                                         $: SVN Revision             *
 *******************************************************************************************************************/

#import "MagicKeyboardAppDelegate.h"
#import <FeedbackReporter/FRFeedbackReporter.h>

@implementation MagicKeyboardAppDelegate

- (id)init {
	self = [super init];
	if( self ) {
		statusBarItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	}
	return self;
}

- (void)dealloc {
	[statusBarItem release];
	[super dealloc];
}

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
}

- (IBAction)quitSelector:(id)sender {
#pragma unused (sender)
	[[NSApplication sharedApplication] terminate:self];
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

- (IBAction)disableTrackingSelector:(id)sender {
	[((NSMenuItem *)sender) setState:!((BOOL)[sender state])];
	
	if( [sender state] ) {
		[window orderOut:self];
		[statusBarItem setImage:[NSImage imageNamed:@"MagicKeyboardMenuDis.png"]];
	} else {
		[window makeKeyAndOrderFront:self];
		[statusBarItem setImage:[NSImage imageNamed:@"MagicKeyboardMenu.png"]];
	}

	[magickeyboard setTracking:![sender state]];
}

- (IBAction)submitFeedback:(id)sender {
#pragma unused (sender)
	[[FRFeedbackReporter sharedReporter] reportFeedback];
}

- (NSDictionary *)customParametersForFeedbackReport {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:@"None found" forKey:@"Devices"];

	if( magickeyboard )
		[dict setObject:[magickeyboard deviceInfoList] forKey:@"Devices"];
	return dict;
}

@end
