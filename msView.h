//
//  msView.h
//  MagicKeyboard
//
//  Created by Michael Nemat on 10-08-14.
//  Copyright 2010 Carleton University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MKButton.h"
#import "MKWindow.h"
#import <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include <Carbon/Carbon.h> /* For kVK_ constants, and TIS functions. */

@interface msView : NSView {
	NSImage* tap;
	NSImage* qwertyLayout;
	NSImage* fullNumLayout;
	NSImage* modsLayout;
	NSImage* numbersLayout;
	NSImage* currentLayout;
	NSImage* symsLayout;
	IBOutlet MKWindow* window;
	IBOutlet NSButton* shiftChk;
	IBOutlet NSButton* cmdChk;
	IBOutlet NSButton* ctlChk;
	IBOutlet NSButton* altChk;
	NSMutableDictionary * prefs;

	IBOutlet NSMenuItem* selQwerty;
	IBOutlet NSMenuItem* selFullNum;
	bool cmd;
	bool alt;
	bool ctl;
	bool doTracking;
    int mtW;
    NSMutableArray* currentButtons;
    id mySelf;
	int mtH;
	 IBOutlet NSImageView* keyboardImage;
    bool shift;
	bool lastKeyWasNotModifier;
}
- (void)resizeWindowOnSpotWithRect:(NSRect)aRect;
- (void) writePrefs : (NSString*) key : (NSString*) value;
-(void)setTracking:(bool)trackingEnabled;
-(IBAction)fullNumSelector:(id)sender;
-(IBAction)halfQwertySelector:(id)sender;
-(void)getButtonsForXMLFile:(NSString*)fileName;
@property (retain) NSImageView* keyboardImage;
@property (retain) NSImage* qwertyLayout;
@property (retain) NSImage* symsLayout;
@property (retain) NSImage* numbersLayout;
@property (retain) NSImage* tap;
@property int mtW;
@property (retain) NSMutableArray* currentButtons;
@property (retain) id mySelf;
@property int mtH;
@property bool shift;
@end
