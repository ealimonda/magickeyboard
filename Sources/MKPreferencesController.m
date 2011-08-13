/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKPreferencesController.m                                                                     *
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

#import "MKPreferencesController.h"
#import "MagicKeyboardAppDelegate.h"
#import "MKController.h"
#import "MKLayout.h"
#import "MKDevice.h"

#pragma mark Implementation
@implementation MKPreferencesController

#pragma mark Initialization
- (id)init {
	self = [super initWithWindowNibName:@"Preferences"];
	if (self) {
		[[self window] setLevel:NSModalPanelWindowLevel];
	}
	return self;
}

- (void)windowDidLoad {
	[super windowDidLoad];
}

#pragma mark NSTableViewDataSource
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
	    row:(NSInteger)rowIndex {
	MagicKeyboardAppDelegate *sharedAppDelegate = (MagicKeyboardAppDelegate *)[[NSApplication
										    sharedApplication] delegate];
	MKController *sharedController = [sharedAppDelegate controller];
	if (aTableView == layoutsTableView) {
		NSArray *layouts = [[sharedController layouts] allValues];
		MKLayout *currentItem = [layouts objectAtIndex:rowIndex];
		if (aTableColumn == layoutsTableSymbol)
			return [currentItem layoutSymbol];
		if (aTableColumn == layoutsTableLayoutName)
			return [currentItem layoutName];
		if (aTableColumn == layoutsTableEnabled)
			return [NSNumber numberWithBool:[[[sharedController currentLayout] layoutIdentifier]
							 isEqualToString:[currentItem layoutIdentifier]]];
	} else if (aTableView == devicesTableView) {
		NSArray *devices = [sharedController devices];
		MKDevice *currentItem = [devices objectAtIndex:rowIndex];
		if (aTableColumn == devicesTableCurrent)
			return [NSNumber numberWithBool:[currentItem isEnabled]];
		if (aTableColumn == devicesTableEnabled)
			return [NSNumber numberWithBool:[currentItem isUsable]];
		if (aTableColumn == devicesTableType)
			return [currentItem deviceType];
		if (aTableColumn == devicesTableID)
			return [NSString stringWithFormat:@"0x%X", [currentItem address]];
	}
	// Unknown table!
	return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn
	      row:(NSInteger)rowIndex {
#pragma unused (anObject, aTableColumn, rowIndex)
	if (aTableView == layoutsTableView) {
		return;
	} else if (aTableView == devicesTableView) {
		return;
	}
	// Unknown table!
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	MagicKeyboardAppDelegate *sharedAppDelegate = (MagicKeyboardAppDelegate *)[[NSApplication
										    sharedApplication] delegate];
	MKController *sharedController = [sharedAppDelegate controller];
	if (aTableView == layoutsTableView) {
		return [[[sharedController layouts] allValues] count];
	} else if (aTableView == devicesTableView) {
		return [[sharedController devices] count];
	}
	// Unknown table!
	return 0;
}

#pragma mark SRRecorder
- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo {
#pragma unused (aRecorder)
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[NSNumber numberWithInteger:newKeyCombo.code] forKey:@"ShortcutKey"];
	[defaults setValue:[NSNumber numberWithUnsignedInteger:newKeyCombo.flags] forKey:@"ShortcutFlags"];
	[defaults synchronize];
}

#if 0
- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags
		  reason:(NSString **)aReason {
#pragma unused (aRecorder, keyCode, flags, aReason)
	return NO;
}

- (BOOL)shortcutRecorderShouldCheckMenu:(SRRecorderControl *)aRecorder {
#pragma unused (aRecorder)
	return NO;
}
#endif // 0

@end
