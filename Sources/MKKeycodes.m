/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKKeycodes.m                                                                                  *
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

#import "MKKeycodes.h"
#import <Carbon/Carbon.h> /* For kVK_ constants, and TIS functions. */
#import "MKButton.h"

@implementation MKKeycodes

/** Returns string representation of key, if it is printable.
 * Ownership follows the Create Rule; that is, it is the caller's
 * responsibility to release the returned object. */
CFStringRef createStringForKey(CGKeyCode keyCode) {
	TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
	CFDataRef layoutData = TISGetInputSourceProperty(currentKeyboard, kTISPropertyUnicodeKeyLayoutData);
	const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
	
	UInt32 keysDown = 0;
	UniChar chars[4];
	UniCharCount realLength;
	
	UCKeyTranslate(keyboardLayout, keyCode, kUCKeyActionDisplay, 0, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit,
		       &keysDown, sizeof(chars)/sizeof(chars[0]), &realLength, chars);
	CFRelease(currentKeyboard);
	
	return CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1);
}

+ (NSInteger)keycodeForCharacter:(NSString *)aCharacter {
	if ([aCharacter length] < 1)
		return -1;
	
	static CFMutableDictionaryRef charToCodeDict = NULL;
	CGKeyCode code;
	UniChar character = [aCharacter characterAtIndex:0];
	CFStringRef charStr = NULL;
	
	/* Generate table of keycodes and characters. */
	if (!charToCodeDict) {
		size_t i;
		charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 128,
							   &kCFCopyStringDictionaryKeyCallBacks, NULL);
		if (!charToCodeDict)
			return -1;
		
		/* Loop through every keycode (0 - 127) to find its current mapping. */
		for (i = 0; i < 128; ++i) {
			CFStringRef string = createStringForKey((CGKeyCode)i);
			if (string != NULL) {
				CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
				CFRelease(string);
			}
		}
	}
	
	charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
	
	/* Our values may be NULL (0), so we need to use this function. */
	if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr, (const void **)&code)) {
		CFRelease(charStr);
		return -1;
	}
	
	CFRelease(charStr);
	return code;
}

+ (NSInteger)keycodeForKeypadCharacter:(NSString *)aCharacter {
	if ([aCharacter isEqualToString:@"."])
		return kVK_ANSI_KeypadDecimal;
	if ([aCharacter isEqualToString:@"*"])
		return kVK_ANSI_KeypadMultiply;
	if ([aCharacter isEqualToString:@"+"])
		return kVK_ANSI_KeypadPlus;
	if ([aCharacter isEqualToString:@"/"])
		return kVK_ANSI_KeypadDivide;
	if ([aCharacter isEqualToString:@"-"])
		return kVK_ANSI_KeypadMinus;
	if ([aCharacter isEqualToString:@"="])
		return kVK_ANSI_KeypadEquals;
	if ([aCharacter isEqualToString:@"0"])
		return kVK_ANSI_Keypad0;
	if ([aCharacter isEqualToString:@"1"])
		return kVK_ANSI_Keypad1;
	if ([aCharacter isEqualToString:@"2"])
		return kVK_ANSI_Keypad2;
	if ([aCharacter isEqualToString:@"3"])
		return kVK_ANSI_Keypad3;
	if ([aCharacter isEqualToString:@"4"])
		return kVK_ANSI_Keypad4;
	if ([aCharacter isEqualToString:@"5"])
		return kVK_ANSI_Keypad5;
	if ([aCharacter isEqualToString:@"6"])
		return kVK_ANSI_Keypad6;
	if ([aCharacter isEqualToString:@"7"])
		return kVK_ANSI_Keypad7;
	if ([aCharacter isEqualToString:@"8"])
		return kVK_ANSI_Keypad8;
	if ([aCharacter isEqualToString:@"9"])
		return kVK_ANSI_Keypad9;
	return -1;
}

+ (NSInteger)keycodeForSpecialKey:(NSString *)aKey {
	if ([aKey isEqualToString:@"KP_ENTER"])
		return kVK_ANSI_KeypadEnter;
	if ([aKey isEqualToString:@"KP_CLEAR"])
		return kVK_ANSI_KeypadClear;
	if ([aKey isEqualToString:@"RETURN"])
		return kVK_Return;
	if ([aKey isEqualToString:@"TAB"])
		return kVK_Tab;
	if ([aKey isEqualToString:@"SPACE"])
		return kVK_Space;
	if ([aKey isEqualToString:@"DELETE"])
		return kVK_Delete;
	if ([aKey isEqualToString:@"ESCAPE"])
		return kVK_Escape;
	if ([aKey isEqualToString:@"COMMAND"])
		return kVK_Command;
	if ([aKey isEqualToString:@"SHIFT"])
		return kVK_Shift;
	if ([aKey isEqualToString:@"CAPS_LOCK"])
		return kVK_CapsLock;
	if ([aKey isEqualToString:@"OPTION"])
		return kVK_Option;
	if ([aKey isEqualToString:@"CONTROL"])
		return kVK_Control;
	if ([aKey isEqualToString:@"SHIFT"])
		return kVK_RightShift;
	if ([aKey isEqualToString:@"OPTIONR"])
		return kVK_RightOption;
	if ([aKey isEqualToString:@"CONTROLR"])
		return kVK_RightControl;
	if ([aKey isEqualToString:@"FN"])
		return kVK_Function;
	if ([aKey isEqualToString:@"F17"])
		return kVK_F17;
	if ([aKey isEqualToString:@"VOL_UP"])
		return kVK_VolumeUp;
	if ([aKey isEqualToString:@"VOL_DOWN"])
		return kVK_VolumeDown;
	if ([aKey isEqualToString:@"VOL_MUTE"])
		return kVK_Mute;
	if ([aKey isEqualToString:@"F18"])
		return kVK_F18;
	if ([aKey isEqualToString:@"F19"])
		return kVK_F19;
	if ([aKey isEqualToString:@"F20"])
		return kVK_F20;
	if ([aKey isEqualToString:@"F5"])
		return kVK_F5;
	if ([aKey isEqualToString:@"F6"])
		return kVK_F6;
	if ([aKey isEqualToString:@"F7"])
		return kVK_F7;
	if ([aKey isEqualToString:@"F3"])
		return kVK_F3;
	if ([aKey isEqualToString:@"F8"])
		return kVK_F8;
	if ([aKey isEqualToString:@"F9"])
		return kVK_F9;
	if ([aKey isEqualToString:@"F11"])
		return kVK_F11;
	if ([aKey isEqualToString:@"F13"])
		return kVK_F13;
	if ([aKey isEqualToString:@"F16"])
		return kVK_F16;
	if ([aKey isEqualToString:@"F14"])
		return kVK_F14;
	if ([aKey isEqualToString:@"F10"])
		return kVK_F10;
	if ([aKey isEqualToString:@"F12"])
		return kVK_F12;
	if ([aKey isEqualToString:@"F15"])
		return kVK_F15;
	if ([aKey isEqualToString:@"HELP"])
		return kVK_Help;
	if ([aKey isEqualToString:@"HOME"])
		return kVK_Home;
	if ([aKey isEqualToString:@"PAGE_UP"])
		return kVK_PageUp;
	if ([aKey isEqualToString:@"FW_DELETE"])
		return kVK_ForwardDelete;
	if ([aKey isEqualToString:@"F4"])
		return kVK_F4;
	if ([aKey isEqualToString:@"END"])
		return kVK_End;
	if ([aKey isEqualToString:@"F2"])
		return kVK_F2;
	if ([aKey isEqualToString:@"PAGE_DOWN"])
		return kVK_PageDown;
	if ([aKey isEqualToString:@"F1"])
		return kVK_F1;
	if ([aKey isEqualToString:@"LEFT"])
		return kVK_LeftArrow;
	if ([aKey isEqualToString:@"RIGHT"])
		return kVK_RightArrow;
	if ([aKey isEqualToString:@"DOWN"])
		return kVK_DownArrow;
	if ([aKey isEqualToString:@"UP"])
		return kVK_UpArrow;
	if ([aKey isEqualToString:@"ISO_SECTION"])
		return kVK_ISO_Section;
	if ([aKey isEqualToString:@"JIS_YEN"])
		return kVK_JIS_Yen;
	if ([aKey isEqualToString:@"JIS_UNDERSCORE"])
		return kVK_JIS_Underscore;
	if ([aKey isEqualToString:@"JIS_KP_COMMA"])
		return kVK_JIS_KeypadComma;
	if ([aKey isEqualToString:@"JIS_EISU"])
		return kVK_JIS_Eisu;
	if ([aKey isEqualToString:@"JIS_KANA"])
		return kVK_JIS_Kana;
	return -1;
}

+ (NSString *)characterforKeyCode:(NSInteger)aKeyCode {
	CFStringRef cfcharacter = createStringForKey((CGKeyCode)aKeyCode);
	NSString *character = [NSString stringWithString:(NSString *)cfcharacter];
	CFRelease(cfcharacter);
	return character;
}

+ (void)sendKeycodeForKey:(NSString *)aSymbol type:(NSString *)aType {
	if ([aType isEqualToString:kButtonTypeKeypad])
		[self sendKeycode:[self keycodeForKeypadCharacter:aSymbol]];
	else if ([aType isEqualToString:kButtonTypeSpecial])
		[self sendKeycode:[self keycodeForSpecialKey:aSymbol]];
	else if ([aType isEqualToString:kButtonTypeSymbol]) {
		if (![self sendKeycodeForLayoutSymbol:aSymbol])
			[self sendKeycodeForUnicodeSymbol:aSymbol];
	}
}

+ (BOOL)sendKeycodeForLayoutSymbol:(NSString *)aSymbol {
	NSInteger code = [self keycodeForCharacter:aSymbol];
	if (code <= -1)
		return NO;
	[self sendKeycode:code];
	return YES;
}

+ (void)sendKeycodeForUnicodeSymbol:(NSString *)aSymbol {
	if ([aSymbol length] < 1)
		return;
	CGEventRef eventDown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)kVK_ANSI_A, true);
	CGEventRef eventUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)kVK_ANSI_A, false);
	unichar unisymbol = [aSymbol characterAtIndex:0];
	CGEventKeyboardSetUnicodeString(eventDown, 1, &unisymbol);
	CGEventKeyboardSetUnicodeString(eventUp, 1, &unisymbol);
	
	CGEventPost(kCGHIDEventTap, eventDown);
	CFRelease(eventDown);
	usleep(50);
	CGEventPost(kCGHIDEventTap, eventUp);
	CFRelease(eventUp);
	usleep(50);
}

+ (void)sendKeycode:(CGKeyCode)keycode {
	// TODO: http://stackoverflow.com/questions/1918841/how-to-convert-ascii-character-to-cgkeycode
	BOOL needsShift = keycode >= 300;
	long flags = 0;
	if (needsShift) {
		keycode -= 300;
	}
//	if (shift || needsShift) {
//		flags |= kCGEventFlagMaskShift;
//	}	
//	if (cmd) {
//		flags |= kCGEventFlagMaskCommand;
//	}
//	if (alt) {
//		flags |= kCGEventFlagMaskAlternate;
//	}
//	if (ctrl) {
//		flags |= kCGEventFlagMaskControl;
//	}
	//NSLog([NSString stringWithFormat:@"%d",keycode]);
	CGEventRef event1, event2;
	event1 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, YES); //'z' keydown event
	event2 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, NO);
	if (flags > 0) {
		CGEventSetFlags(event1, flags);//set shift key down for above event
		CGEventSetFlags(event2, flags);//set shift key down for above event
	} else {
		CGEventSetFlags(event1, 0);//set shift key down for above event
		CGEventSetFlags(event2, 0);//set shift key down for above event
	}
	CGEventPost(kCGHIDEventTap, event1);//post event
	CFRelease(event1);
	usleep(50);
	CGEventPost(kCGHIDEventTap, event2);//post event
	CFRelease(event2);
	usleep(50);
//	if (shift || needsShift) {
//		CGEventRef shiftUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)56, NO);//'z' keydown event
//		CGEventPost(kCGHIDEventTap, shiftUp);//post event
//		CFRelease(shiftUp);
//		usleep(50);
//	}
//	if (cmd) {
//		CGEventRef cmdUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)55, NO);//'z' keydown event
//		CGEventPost(kCGHIDEventTap, cmdUp);//post event
//		CFRelease(cmdUp);
//		usleep(50);
//	}
//	if (alt) {
//		CGEventRef altUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)58, NO);//'z' keydown event
//		CGEventPost(kCGHIDEventTap, altUp);//post event
//		CFRelease(altUp);
//		usleep(50);
//	}
//	if (ctrl) {
//		CGEventRef ctrlUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)59, NO);//'z' keydown event
//		CGEventPost(kCGHIDEventTap, ctrlUp);//post event
//		CFRelease(ctrlUp);
//		usleep(50);
//	}
}

@end
