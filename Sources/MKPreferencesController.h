/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKPreferencesController.h                                                                     *
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

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>

#pragma mark Constants
extern NSString * const kSettingCurrentLayout;
extern NSString * const kSettingGlobalHotkey;
extern NSString * const kSettingGlobalHotkeyEnabled;
extern NSString * const kSettingHoldFnToTrack;
extern NSString * const kSettingHoldCornerToTrack;
extern NSString * const kSettingHoldCornerPosition;
extern NSString * const kSettingIgnoreTrackpadInput;
extern NSString * const kSettingVerticalPosition;
extern NSString * const kSettingHorizontalPosition;
extern NSString * const kSettingSUAutomaticallyUpdate;
extern NSString * const kSettingSUEnableAutomaticChecks;
extern NSString * const kSettingSUScheduledCheckInterval;
extern NSString * const kSettingSUSendProfileInfo;

#pragma mark Interface
@interface MKPreferencesController : NSWindowController <NSTableViewDataSource> {
	IBOutlet SRRecorderControl *shortcutRecorder;
	
	IBOutlet NSTableView *layoutsTableView;
	IBOutlet NSTableColumn *layoutsTableSymbol;
	IBOutlet NSTableColumn *layoutsTableEnabled;
	IBOutlet NSTableColumn *layoutsTableLayoutName;
	
	IBOutlet NSTableView *devicesTableView;
	IBOutlet NSTableColumn *devicesTableCurrent;
	IBOutlet NSTableColumn *devicesTableEnabled;
	IBOutlet NSTableColumn *devicesTableType;
	IBOutlet NSTableColumn *devicesTableID;
}

#pragma mark Methods
//- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags
//		  reason:(NSString **)aReason;
//- (BOOL)shortcutRecorderShouldCheckMenu:(SRRecorderControl *)aRecorder;
- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo;
- (IBAction)setHotkey:(id)sender;

@end
