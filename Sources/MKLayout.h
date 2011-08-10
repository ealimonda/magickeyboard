/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKLayout                                                   *
 *******************************************************************************************************************
 * File:             MKLayout.h                                                                                    *
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
#import "MKLayoutDefinition.h"

#pragma mark Interface
@interface MKLayout : NSObject {
	NSString *layoutIdentifier;
	NSString *layoutName;
	NSString *layoutSymbol;
	NSSize layoutSize;
	NSImage *keyboardImage;
	NSMutableArray *currentButtons;
	BOOL valid;
	MKLayoutDefinition *layoutDefinition;
}

#pragma mark Methods
- (id)initWithName:(NSString *)loadName;
+ (id)layout;
+ (id)layoutWithName:(NSString *)loadName;

- (void)loadPlist:(NSString *)fileName;

- (void)loadLayoutDefinition:(NSString *)definitionName;

- (NSArray *)createLabelsUsingSymbolsForLayouts:(NSDictionary *)layouts;

#pragma mark Properties
@property (retain) NSString *layoutIdentifier;
@property (retain) NSString *layoutName;
@property (retain) NSString *layoutSymbol;
@property (assign) NSSize layoutSize;
@property (retain) NSImage *keyboardImage;
@property (readonly,retain) NSMutableArray *currentButtons;
@property (assign,getter=isValid) BOOL valid;
@property (retain) MKLayoutDefinition *layoutDefinition;

@end
