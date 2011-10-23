/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKLayoutDefinition                                         *
 *******************************************************************************************************************
 * File:             MKLayoutDefinition.h                                                                          *
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
#import "MKButton.h"

extern NSString * const kStyleDefault;
extern NSString * const kStyleIOs;
extern NSString * const kStyleAluminium;

#pragma mark Interface
@interface MKLayoutDefinition : NSObject {
	NSString *layoutDefinitionName;
	NSSize layoutSize;
	NSImage *keyboardImage;
	NSMutableArray *currentButtons;
	NSString *style;
	BOOL valid;
}

#pragma mark Methods
- (id)initWithName:(NSString *)loadName;
+ (id)layoutDefinition;
+ (id)layoutDefinitionWithName:(NSString *)loadName;

- (void)loadPlist:(NSString *)fileName;

- (MKButton *)buttonWithID:(NSInteger)buttonID;

#pragma mark Properties
@property (retain) NSString *layoutDefinitionName;
@property (assign) NSSize layoutSize;
@property (retain) NSImage *keyboardImage;
@property (readonly,retain) NSMutableArray *currentButtons;
@property (retain) NSString *style;
@property (assign,getter=isValid) BOOL valid;

@end
