//
//  MagicKeyboardAppDelegate.m
//  MagicKeyboard
//
//  Created by Michael Nemat on 10-08-14.
//

#import "MagicKeyboardAppDelegate.h"

@implementation MagicKeyboardAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[window setAcceptsMouseMovedEvents:NO];
	//CGDisplayHideCursor(kCGDirectMainDisplay);
	//CGAssociateMouseAndMouseCursorPosition(false);
	[window setLevel:NSFloatingWindowLevel];
	[window setCollectionBehavior:NSWindowCollectionBehaviorStationary];
	NSStatusItem* statusBarItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	NSImage* statusImage = [NSImage imageNamed:@"trayicon.png"];
	[statusBarItem setImage:statusImage];
	[statusBarItem setHighlightMode:YES];
	[statusBarItem setMenu:statusMenu];
	
}
-(IBAction)quitSelector:(id)sender{
	[[NSApplication sharedApplication] terminate:self];
}

-(BOOL) acceptsFirstResponder {
	return NO;
}
-(IBAction)disableTrackingSelector:(id)sender{
	[((NSMenuItem*)sender) setState:!((bool)[sender state])];
	if ([sender state]){
		[window orderOut:self];
	} else {
		[window makeKeyAndOrderFront:self];
	}
	[magickeyboard setTracking:![sender state]];
}

@end
 








