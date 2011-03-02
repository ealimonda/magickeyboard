//
//  MagicKeyboardAppDelegate.h
//  MagicKeyboard
//
//  Created by Michael Nemat on 10-08-14.
//  Copyright 2010 Carleton University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "msView.h"

@interface MagicKeyboardAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSMenu* statusMenu;
	IBOutlet msView* magickeyboard;
}
-(IBAction)disableTrackingSelector:(id)sender;
-(IBAction)quitSelector:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
