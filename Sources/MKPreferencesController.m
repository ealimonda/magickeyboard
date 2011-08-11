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

#pragma mark Implementation
@implementation MKPreferencesController

#pragma mark Initialization
- (id)init {
	self = [super initWithWindowNibName:@"Preferences"];
	if (self) {
		[[self window] setLevel:NSModalPanelWindowLevel];
		// Initialization code here.
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
	}
	// Unknown table!
	return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn
	      row:(NSInteger)rowIndex {
#pragma unused (anObject, aTableColumn, rowIndex)
	if (aTableView == layoutsTableView) {
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
	}
	// Unknown table!
	return 0;
}

@end
