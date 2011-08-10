/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKKeyboard.h                                                                                  *
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

#import <Foundation/Foundation.h>
#import "MKButton.h"

#pragma mark Interface
@interface MKKeyboard : NSObject {
	BOOL shiftDown;
	BOOL optDown;
	BOOL cmdDown;
	BOOL ctrlDown;
}

#pragma mark Methods
+ (NSInteger)keycodeForCharacter:(NSString *)aCharacter;
+ (NSInteger)keycodeForKeypadCharacter:(NSString *)aCharacter;
+ (NSInteger)keycodeForSpecialKey:(NSString *)aKey;
+ (NSString *)characterforKeyCode:(NSInteger)aKeyCode;

- (void)sendKeycodeForKey:(NSString *)aKey type:(NSString *)aType;
- (BOOL)sendKeycodeForLayoutSymbol:(NSString *)aSymbol;
- (void)sendKeycodeForUnicodeSymbol:(NSString *)aSymbol;
- (void)sendKeycode:(CGKeyCode)keycode sticky:(BOOL)isSticky;

@property (assign,getter=isShiftDown) BOOL shiftDown;
@property (assign,getter=isOptDown) BOOL optDown;
@property (assign,getter=isCmdDown) BOOL cmdDown;
@property (assign,getter=isCtrlDown) BOOL ctrlDown;

@end
